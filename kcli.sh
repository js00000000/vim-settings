#!/bin/bash

# Function to show error message in red
error() {
    echo -e "\e[31m$1\e[0m"
}

# Function to show success message in green
success() {
    echo -e "\e[32m$1\e[0m"
}

# Function to display current cluster and namespace
display_current_state() {
    if [[ -n "$KUBECONFIG" ]]; then
        current_cluster=$(kubectl config view --minify -o jsonpath='{.clusters[0].name}')
        success "Current cluster: $current_cluster"
    else
        error "KUBECONFIG is not set."
    fi
    
    if [[ -z "$chosen_namespace" ]]; then
        success "Current namespace: all namespaces"
    else
        success "Current namespace: $chosen_namespace"
    fi
}

# Function to select cluster from a dynamic list
choose_cluster() {
    echo "Available clusters:"
    # Dynamically list all files in ~/.kube/configs
    configs=(~/.kube/configs/*.yaml)
    for i in "${!configs[@]}"; do
        echo "$((i+1))) ${configs[$i]##*/}"
    done

    read -p "Select an cluster (or press Enter for default [stg]): " cluster_choice
    
    # Default to stg.yaml if no input
    cluster_choice=${cluster_choice:-2}

    if [[ $cluster_choice -ge 1 && $cluster_choice -le ${#configs[@]} ]]; then
        export KUBECONFIG=${configs[$((cluster_choice-1))]}
        success "KUBECONFIG set to ${configs[$((cluster_choice-1))]##*/}."
    else
        error "Invalid choice. Please try again."
        choose_cluster
    fi
}

# Global variable to store the chosen namespace
chosen_namespace=""

# Function to choose namespace with optional parameter to allow choosing all namespaces
choose_namespace() {
    local allow_all=$1
    if [[ -z "$allow_all" ]]; then
        allow_all=true
    fi

    echo "Available namespaces:"
    kubectl get namespaces | cut -d/ -f2
    if [[ "$allow_all" == "true" ]]; then
        echo "0) All namespaces"
    fi
    read -p "Enter namespace (or press Enter for all namespaces): " namespace
    if [[ -z "$namespace" ]]; then
        if [[ "$allow_all" == "true" ]]; then
            chosen_namespace=""
            success "Namespace set to all namespaces."
        else
            error "Namespace is required."
            choose_namespace false
        fi
    else
        chosen_namespace=${namespace}
        success "Namespace set to $chosen_namespace."
    fi
}

# Function to execute custom kubectl command
execute_custom_command() {
    read -p "Enter your custom kubectl command: " custom_command
    if [[ -z "$chosen_namespace" ]]; then
        echo -e "\033[0;33mExecuting: kubectl $custom_command\033[0m"
        eval "kubectl $custom_command"
    else
        echo -e "\033[0;33mExecuting: kubectl -n $chosen_namespace $custom_command\033[0m"
        eval "kubectl -n $chosen_namespace $custom_command"
    fi
}

# Function to check released pods
check_released_pods() {
    read -p 'Enter the grep pattern: ' grep_pattern
    if [[ -z "$chosen_namespace" ]]; then
        kubectl get pods --all-namespaces -o=jsonpath="{range .items[*]}{.metadata.namespace}{': '}{.metadata.name}{': '}{range .spec.containers[*]}{.image}{' '}{end}{'\n'}{end}" | grep $grep_pattern
    else
        kubectl get pods -n $chosen_namespace -o=jsonpath="{range .items[*]}{.metadata.name}{': '}{range .spec.containers[*]}{.image}{' '}{end}{'\n'}{end}" | grep $grep_pattern
    fi
}

# Function to get appsettings.json from pod
get_appsettings_from_pod() {
    if [[ -z "$chosen_namespace" ]]; then
        choose_namespace false
    fi
    read -p 'Enter the grep pattern: ' grep_pattern
    pods=()
    pods=($(kubectl get pods -n $chosen_namespace -o=jsonpath="{range .items[*]}{.metadata.name}{':'}{range .spec.containers[*]}{.image}{' '}{end}{'\n'}{end}" | grep $grep_pattern))
    if [[ ${#pods[@]} -eq 0 ]]; then
        error "No pods found matching the grep pattern."
    else
        echo "Available pods matching the grep pattern:"
        for i in "${!pods[@]}"; do
            echo "$((i+1))) ${pods[$i]}"    # Extract only the pod name when echo
        done
        read -p "Select a pod (or press Enter to exit): " pod_choice
        if [[ -z "$pod_choice" ]]; then
            return
        fi
        pod_name=${pods[$((pod_choice-1))]%%:*}  # Extract only the pod name for kubectl exec
        pod_content=$(kubectl exec -n $chosen_namespace $pod_name -- cat appsettings.json)
        if [[ -z "$pod_content" ]]; then
            error "appsettings.json not found in pod $pod_name."
        else
            echo "$pod_content" > appsettings.development.json
            echo -e "\e[32mFile path: $(pwd)/appsettings.development.json\e[0m"
        fi
    fi
}

# Function to choose an action (get namespace, pods, or other Kubernetes resources)
choose_action() {
    echo "What do you want to do?"
    echo "1) Get pods"
    echo "2) Get services"
    echo "3) Get deployments"
    echo "4) Execute custom command"
    echo "5) Choose namespace"
    echo "6) Choose cluster"
    echo "7) Check released pods"
    echo "8) Get appsettings.json from pod"
    echo "0) Exit"
    
    read -p "Enter your choice (1/2/3/4/5/6/7/8/0): " action_choice
    
    case $action_choice in
        1)
            if [[ -z "$chosen_namespace" ]]; then
                kubectl get pods --all-namespaces
            else
                kubectl get pods -n $chosen_namespace
            fi
            ;;
        2)
            if [[ -z "$chosen_namespace" ]]; then
                kubectl get services --all-namespaces
            else
                kubectl get services -n $chosen_namespace
            fi
            ;;
        3)
            if [[ -z "$chosen_namespace" ]]; then
                kubectl get deployments --all-namespaces
            else
                kubectl get deployments -n $chosen_namespace
            fi
            ;;
        4)
            execute_custom_command
            ;;
        5)
            choose_namespace true
            ;;
        6)
            choose_cluster
            ;;
        7)
            check_released_pods
            ;;
        8)
            get_appsettings_from_pod
            ;;
        0)
            echo "Exiting..."
            exit 0
            ;;
        *)
            error "Invalid choice. Please try again."
            ;;
    esac
}

# Optional help message
show_help() {
    echo "Usage: kcli.sh [--help]"
    echo ""
    echo "Interactive shell script to manage Kubernetes clusters."
    echo "Options:"
    echo "  --help      Show this help message."
}

# Main execution
if [[ "$1" == "--help" ]]; then
    show_help
    exit 0
fi

# Check if KUBECONFIG is set, if not, ask user to set it
if [[ -z "$KUBECONFIG" ]]; then
    error "KUBECONFIG is not set."
    choose_cluster
else
    success "Current KUBECONFIG: $KUBECONFIG"
fi

while true; do
    display_current_state
    choose_action
    echo ""
done