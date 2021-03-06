##
## Makefile for deployment of CartoWeb applications
##  CartoWeb specific rules
##
## Copyright 2005, Sylvain Pasche Camptocamp SA
## $Id$


# ###################################
# Documentation
# ###################################

# fetch_all_instances
# fetch_instance/INSTANCE
# fetch_project/PROJECT
#
# deploy_all_instances
# deploy_instance/INSTANCE

# Database commands:
#  See documentation in scripts/db_deploy.mk

REV := $Revision$

# Compatibility checking.
#  This should be updated when an incompatible change is done
CURRENT_COMPAT_VERSION := 0

ifneq ($(CURRENT_COMPAT_VERSION), $(COMPAT_VERSION))
       $(error Your Makefile version $(COMPAT_VERSION) is not compatible with \
	the new deploy version $(CURRENT_COMPAT_VERSION), see the update information \
	on http://cartoweb.org/cwiki/AutomaticDeployment\#makefile_update and update your Makefile)
endif

# variable setup
HOSTNAME := $(shell cat /etc/hostname)

default_CW3_NAME = $(cur_project)

# Variable expansion

define override_template
ifdef $$($(1))_$(2)
        $(2) := $$($$($(1))_$(2))
endif
endef

HOSTS_VARS := FQHN TARGET_HOST
$(foreach v,$(HOSTS_VARS), $(eval $(call override_template,HOSTNAME,$(v))))

# Creates a directory recursively if it does not exist 
#
# $(1) directory name
define makedirs
	@test -d $(1) || mkdir -p $(1) && :
endef

all:
	:

define fetch_cw3setup
 test -f cw3setup.php && rm cw3setup.php || :; \
 test -d tmp && rm -rf tmp || :; \
 mkdir tmp; \
 (cd tmp && \
  svn export $(SVNROOT_CW)trunk/cw3setup.php); \
 mv tmp/cw3setup.php . ; \
 rm -rf tmp
endef

cur_make_target = $(filter-out %/,$(subst /,/ ,$@))

cur_project = $(cur_make_target)

define cur_cw_project
$(call get_proj_var,CW3_NAME)
endef

cur_project_target = cartowebs/$($(cur_project)_INSTANCE)

define get_var
$(if $($($(1))_$(2)),$($($(1))_$(2)),$(default_$(2)))
endef

define get_inst_var
$(call get_var,cur_instance,$(1))
endef

define get_proj_var
$(call get_var,cur_project,$(1))
endef

# ###################################
# Update config

$(patsubst %,update_config_project/%,$(ALL_PROJECTS)) :: update_config_project/% :
	echo Project $(cur_project)
	(cd $(cur_project_target)/cartoweb3; $(PHP) cw3setup.php --clean)
	(cd $(cur_project_target)/cartoweb3; CW3_VARS='$(call get_proj_var,CW3_VARS)' $(PHP) cw3setup.php --install \
			$(if $(call get_proj_var,NO_DEPLOY_CONFIG),,--config-from-project $(cur_cw_project)) --project $(cur_cw_project) )

	$(if $(call get_proj_var,BASE_URL),\
		perl -pi -e 's#^;?cartoclientBaseUrl = ".*"$$#cartoclientBaseUrl = "$(call get_proj_var,BASE_URL)"#g' \
			$(cur_project_target)/cartoweb3/client_conf/client.ini; \
		perl -pi -e 's#^;?cartoserverBaseUrl = ".*"$$#cartoserverBaseUrl = "$(call get_proj_var,BASE_URL)"#g' \
			$(cur_project_target)/cartoweb3/client_conf/client.ini; \
	)

# ###################################
# Project fetching

$(patsubst %,pre_fetch_project/%,$(ALL_PROJECTS)) :: pre_fetch_project/% :
	@echo Pre Fetching project $(cur_project)

	$(if $(call get_proj_var,SVN_CO_OPTIONS),\
		(cd $(cur_project_target)/cartoweb3; $(PHP) cw3setup.php --install  --fetch-project-svn $(cur_cw_project)  \
				--base-url _undefined_ --delete-existing --svn-co-options "$(call get_proj_var,SVN_CO_OPTIONS)" ) \
	,\
		(cd $(cur_project_target)/cartoweb3; $(PHP) cw3setup.php --install  --fetch-project-cvs $(cur_cw_project)  \
				--base-url _undefined_ --delete-existing $(if $(call get_proj_var,CVSROOT),--cvs-root $(call get_proj_var,CVSROOT)) ) \
	)

	echo "<?php \$$_ENV['CW3_PROJECT'] = '$(cur_cw_project)'; require_once('client.php'); ?>" > \
		$(cur_project_target)/cartoweb3/htdocs/$(cur_cw_project).php
	$(call makedirs,htdocs)
	@test -h htdocs/$(cur_cw_project) && rm htdocs/$(cur_cw_project) || :
	ln -s ../cartowebs/$(call get_proj_var,INSTANCE)/cartoweb3/htdocs htdocs/$(cur_cw_project)


$(patsubst %,post_fetch_project/%,$(ALL_PROJECTS)) :: post_fetch_project/% : update_config_project/%
	@echo Post Fetching project $@

$(patsubst %,fetch_project/%,$(ALL_PROJECTS)) :: fetch_project/% : check_user pre_fetch_project/% post_fetch_project/%


# ###################################
# Instance fetching

# $(1) instance name
define projects_for_instance
	$(foreach p,$(ALL_PROJECTS),$(if $(filter $(1),$($(p)_INSTANCE)),$(p),))
endef

define targets_for_instance
	$(patsubst %,$(1)/%,$(call projects_for_instance,$(2)))
endef

cur_instance = $(cur_make_target)
cur_target = cartowebs/$(cur_instance)

instance_svn_option = $(if $(call get_inst_var,REVISION), --cartoweb-svn-option $(call get_inst_var,REVISION))
instance_tag = $(if $(call get_inst_var,TAG),tags/$$(echo $(call get_inst_var,TAG)),trunk)

SED_CMD := sed 's/^.*evision: \([^ ]*\) .*$$/\1/g'

$(patsubst %,pre_fetch_instance/%,$(ALL_INSTANCES)) :: pre_fetch_instance/% : # $(call targets_for_instance,%) # This does not work for unknown reason!
	@echo "### Fetching instance $(cur_instance)"

	$(call makedirs,$(cur_target))

	(cd $(cur_target)&& $(call fetch_cw3setup,$(call get_inst_var,REVISION)))
	test -f $(cur_target)/cw3setup.php || { echo "Error: Couldn't fetch cw3setup.php"; exit -1; }

ifndef NO_CONFIRM
	@if [ -d $(cur_target)/cartoweb3 ]; then \
		read -p "Warning: The $(cur_target)/cartoweb3 directory will be removed, unsaved changes will be lost. Press <ctrl-c> to stop, or enter to continue"; \
		rm -rf $(cur_target)/cartoweb3 ;\
	fi
endif
	(cd $(cur_target)&& CW3_NO_VERSION_CHECK=1 $(PHP) cw3setup.php --profile production --install --fetch-from-svn $(instance_svn_option) \
			--svn-root $(SVNROOT_CW)$(instance_tag) --delete-existing --base-url _undefined_)

	@# Override cw3setup.php with this one
	@# XXX why is this needed, and what is "this one"???
	@#  Define NO_CW3SETUP_OVERRIDE to prevent this
	#$(if $(call get_proj_var,NO_CW3SETUP_OVERRIDE),,cp cw3setup.php $(cur_target)/cartoweb3/)

	@# Version check
	@new_version=$$(grep 'RE[V].*ev.sion:' $(cur_target)/cartoweb3/scripts/deploy/rules.mk | $(SED_CMD)); \
	this_version=$$(echo "$(REV)" | $(SED_CMD)); \
	echo "Deploy version just fetched: $$new_version; current version: $$this_version"; \
	if test -n "$$new_version"; then \
	dpkg --compare-versions $$new_version gt $$this_version && \
		read -p "Warning: A new version of the deploy script is available. Press enter to continue, or control-c to abort so that you can update. See http://cartoweb.org/cwiki/AutomaticDeployment#deploy_update" \
		|| : \
	else true; \
	fi

$(patsubst %,post_fetch_instance/%,$(ALL_INSTANCES)) :: post_fetch_instance/% :
	$(foreach target,$(call targets_for_instance,fetch_project,$(cur_instance)),\
		$(MAKE) $(target) || exit -1;\
	)


$(patsubst %,fetch_instance/%,$(ALL_INSTANCES)) :: fetch_instance/% : check_user pre_fetch_instance/% post_fetch_instance/%


fetch_all_instances: $(patsubst %,fetch_instance/%,$(ALL_INSTANCES))

# ###################################
# Synchronisation

# $(1) directory name
define remote_makedirs
	ssh $(TARGET_HOST) 'test -d $(1) || mkdir -p $(1) && :'
endef

$(patsubst %,sync_instance/%,$(ALL_INSTANCES)) :: sync_instance/% :
	$(call remote_makedirs,$(TOPSRCDIR)/$(cur_target)/cartoweb3/)
	rsync $(RSYNC_FLAGS) --exclude 'www-data/*'  --exclude 'htdocs/generated' \
	  --exclude 'templates_c/*' --delete -av \
	  $(TOPSRCDIR)/$(cur_target)/cartoweb3/ $(TARGET_HOST):$(TOPSRCDIR)/$(cur_target)/cartoweb3/

check_user:
ifdef REQUIRED_USER
	@if [ $$(whoami) != "$(REQUIRED_USER)" ]; then \
		echo "You should run this script with $(REQUIRED_USER) user, exitting";\
		exit -1 ;\
	fi
endif

sync_misc:
	#ssh $(TARGET_HOST) 'test -d $(TOPSRCDIR) || mkdir -p $(TOPSRCDIR)'
	$(call remote_makedirs,$(TOPSRCDIR))
	rsync $(RSYNC_FLAGS) -av $(TOPSRCDIR)/Makefile $(TARGET_HOST):$(TOPSRCDIR)/Makefile
	rsync $(RSYNC_FLAGS) -av $(TOPSRCDIR)/deploy $(TARGET_HOST):$(TOPSRCDIR)/

	test -f apache.conf && rsync $(RSYNC_FLAGS) -av $(TOPSRCDIR)/apache.conf $(TARGET_HOST):$(TOPSRCDIR)/ || :
	test -f local.mk && rsync $(RSYNC_FLAGS) -av $(TOPSRCDIR)/local.mk $(TARGET_HOST):$(TOPSRCDIR)/ || :
	rsync $(RSYNC_FLAGS) -av $(TOPSRCDIR)/htdocs $(TARGET_HOST):$(TOPSRCDIR)/
	test -d *_management && rsync $(RSYNC_FLAGS) -av $(TOPSRCDIR)/*_management $(TARGET_HOST):$(TOPSRCDIR)/ || :
	#rsync $(RSYNC_FLAGS) -av $(TOPSRCDIR)/searchserver $(TARGET_HOST):$(TOPSRCDIR)/
	#rsync $(RSYNC_FLAGS) -av $(TOPSRCDIR)/mapfiles $(TARGET_HOST):$(TOPSRCDIR)/
	#rsync $(RSYNC_FLAGS) -av $(TOPSRCDIR)/kogis_management $(TARGET_HOST):$(TOPSRCDIR)/

$(patsubst %,deploy_instance/%,$(ALL_INSTANCES)) :: deploy_instance/% : check_user sync_misc sync_instance/%
	echo $(PROJECTS)
	$(foreach target,$(call targets_for_instance,update_config_project,$(cur_instance)),\
		ssh $(TARGET_HOST) $(MAKE) -C $(TOPSRCDIR) $(target) || exit -1;\
	)

deploy_all_instances: $(patsubst %,deploy_instance/%,$(ALL_INSTANCES))


# ###################################
# Database synchronisation
# ###################################

include $(TOPSRCDIR)/deploy/db_deploy.mk

# ###################################

# TODO
.PHONY: all 
