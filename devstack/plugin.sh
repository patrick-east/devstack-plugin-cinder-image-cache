# plugin.sh - DevStack plugin.sh dispatch script

function configure_internal_tenant {
    # If either id is empty we will create a new project/username for the internal tenant
    if [[ -z $CINDER_INTERNAL_TENANT_PROJECT_ID || -z $CINDER_INTERNAL_TENANT_USER_ID ]]; then
        export CINDER_INTERNAL_TENANT_PROJECT_ID=$(get_or_create_project "$CINDER_INTERNAL_TENANT_PROJECTNAME" default)
        export CINDER_INTERNAL_TENANT_USER_ID=$(get_or_create_user "$CINDER_INTERNAL_TENANT_USERNAME" "$CINDER_INTERNAL_TENANT_PASSWORD" default)
        local admin_role
        admin_role=$(get_or_create_role "admin")
        get_or_add_user_project_role $admin_role $CINDER_INTERNAL_TENANT_USER_ID $CINDER_INTERNAL_TENANT_PROJECT_ID
    fi

    iniset $CINDER_CONF DEFAULT cinder_internal_tenant_project_id $CINDER_INTERNAL_TENANT_PROJECT_ID
    iniset $CINDER_CONF DEFAULT cinder_internal_tenant_user_id $CINDER_INTERNAL_TENANT_USER_ID
}

function configure_cache {
    # Expect CINDER_CACHE_ENABLED_FOR_BACKENDS to be a list of backends
    # similar to CINDER_ENABLED_BACKENDS with NAME:TYPE where NAME will
    # be the backend specific configuration stanza in cinder.conf.
    for be in ${CINDER_CACHE_ENABLED_FOR_BACKENDS//,/ }; do
        be_name=${be##*:}

        iniset $CINDER_CONF $be_name image_volume_cache_enabled $CINDER_IMG_CACHE_ENABLED

        if [[ -n $CINDER_IMG_CACHE_SIZE_GB ]]; then
            iniset $CINDER_CONF $be_name image_volume_cache_max_size_gb $CINDER_IMG_CACHE_SIZE_GB
        fi

        if [[ -n $CINDER_IMG_CACHE_SIZE_GB ]]; then
            iniset $CINDER_CONF $be_name image_volume_cache_max_count $CINDER_IMG_CACHE_SIZE_COUNT
        fi
    done
}

function setup_image_cache {
    configure_internal_tenant
    configure_cache
}

# check for service enabled
if is_service_enabled c-vol; then

    if [[ "$1" == "stack" && "$2" == "pre-install" ]]; then
        # no-op
        :

    elif [[ "$1" == "stack" && "$2" == "install" ]]; then
        # no-op
        :

    elif [[ "$1" == "stack" && "$2" == "post-config" ]]; then
        echo_summary "Configuring Cinder Glance image cache"
        setup_image_cache

    elif [[ "$1" == "stack" && "$2" == "extra" ]]; then
        # no-op
        :
    fi

    if [[ "$1" == "unstack" ]]; then
        # no-op
        :
    fi

    if [[ "$1" == "clean" ]]; then
        # no-op
        :
    fi
fi
