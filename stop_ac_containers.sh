#!/bin/bash

# Array of container names
CONTAINERS=( "postgresql1" "dovecot1" "postfix1" "nginx1" "ejabberd1" )

NON_INTERACTIVE=false
for arg in "$@"; do
    if [[ "$arg" == "--non-interactive" ]]; then
        NON_INTERACTIVE=true
    fi
done

# Function to ask whether to continue if an error occurs
ask_continue() {
    if [ "$NON_INTERACTIVE" = false ]; then
        read -p "An error occurred. Do you want to continue stopping containers? (y/n): " choice
        case "$choice" in
            y|Y ) echo "Continuing...";;
            n|N ) echo "Stopping script execution."; exit 1;;
            * ) echo "Invalid choice, stopping execution."; exit 1;;
        esac
    else
        echo "Error, script terminated in non-interactive mode."
        exit 1
    fi
}

# Stopping containers
for container in "${CONTAINERS[@]}"; do
    echo "Stopping container: $container..."
    #podman stop "$container" && podman rm "$container"
    podman stop "$container" > /tmp/podman_container_stop.log 2>&1 && podman rm "$container" > /tmp/podman_container_stop.log 2>&1
    if [ $? -ne 0 ]; then
        echo "Error stoping container. Details:"
        cat /tmp/podman_container_stop.log
        ask_continue
    fi
done

# Remove network if no containers are running
if ! podman ps -a --format '{{.Names}}' | grep -q .; then
    echo "No running containers detected. Removing network..."
    podman network rm "${CONTAINERS_NETWORK_NAME:-ac_network}" > /tmp/podman_network_stop.log 2>&1
fi

echo "All specified containers have been stopped and removed."
