#!/bin/bash

# ======================================
# Azure DevOps Pipeline Trigger Script
# ======================================
#
# DESCRIZIONE:
#   Questo script si occupa di triggerare una pipeline Azure DevOps tramite API REST.
#
# PREREQUISITI:
#   - curl installato
#   - jq installato (opzionale, per formattare l'output JSON)
#
# CONFIGURAZIONE:
#   1. Genera un Personal Access Token (PAT) in Azure DevOps:
#      - Vai su https://dev.azure.com/{organization}/_usersSettings/tokens
#      - Crea un nuovo token con i permessi "Build (read and execute)"
#
#   2. Esporta il PAT come variabile d'ambiente:
#      export AZDO_PAT="il-tuo-pat-token"
#
#   3. Configura i template parameters in uno dei seguenti modi:
#      
#      A) Usando un file JSON (params.json):
#         {
#           "APPS_TOP": "[one-color]",
#           "ARGOCD_TARGET_BRANCH": "tmp",
#           "POSTMAN_BRANCH": "develop",
#           "TRIGGER_MESSAGE": "p4pa-auth"
#         }
#      
#      B) Tramite variabile d'ambiente:
#         export AZDO_TEMPLATE_PARAMETERS='{"APPS_TOP":"[one-color]"}'
#
#   4. Modifica le variabili di configurazione sotto secondo le tue necessità
#
# UTILIZZO:
#   ./trigger-pipeline.sh [path/to/params.json]
#
# ======================================

# Exit on error
set -e

# ===================
# CONFIGURAZIONE
# ===================
AZDO_ORGANIZATION="pagopaspa"
AZDO_PROJECT="p4pa-projects"
AZDO_PIPELINE_ID="2111"
AZDO_BRANCH="main"  # Branch da utilizzare per il trigger

# Logging function
log() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $1"
}

# Function to load template parameters
load_template_parameters() {
    # Se viene fornito un file come argomento
    if [ -n "$1" ]; then
        if [ ! -f "$1" ]; then
            log "ERROR: File $1 non trovato"
            exit 1
        fi
        
        # Verifica che il file contenga JSON valido
        if ! jq . "$1" >/dev/null 2>&1; then
            log "ERROR: Il file $1 non contiene JSON valido"
            exit 1
        fi
        
        AZDO_TEMPLATE_PARAMETERS=$(cat "$1")
        log "Template parameters caricati dal file: $1"
    else
        # Se non c'è un file, verifica la variabile d'ambiente
        if [ -z "$AZDO_TEMPLATE_PARAMETERS" ]; then
            log "ERROR: Nessun template parameter fornito. Puoi fornirli in due modi:"
            log "1. Passando un file JSON come argomento: ./trigger-pipeline.sh params.json"
            log "2. Impostando la variabile d'ambiente AZDO_TEMPLATE_PARAMETERS"
            exit 1
        fi
        
        # Verifica che la variabile d'ambiente contenga JSON valido
        if ! echo "$AZDO_TEMPLATE_PARAMETERS" | jq . >/dev/null 2>&1; then
            log "ERROR: AZDO_TEMPLATE_PARAMETERS non contiene JSON valido"
            exit 1
        fi
        
        log "Template parameters caricati da variabile d'ambiente"
    fi
    
    # Mostra i parameters caricati
    log "Parameters configurati:"
    echo "$AZDO_TEMPLATE_PARAMETERS" | jq .
}

# Function to check required variables
check_pat() {
    if [ -z "$AZDO_PAT" ]; then
        log "ERROR: AZDO_PAT non impostato. Per favore impostalo usando:"
        log "export AZDO_PAT=your-pat-token"
        exit 1
    fi
}

# Function to trigger pipeline
trigger_pipeline() {
    local api_version="7.1"
    
    # Create auth token
    local auth_token=$(echo -n ":$AZDO_PAT" | base64)
    
    # Log execution start
    log "Triggering pipeline sul branch: $AZDO_BRANCH"
    
    # Prepare API URL
    local api_url="https://dev.azure.com/$AZDO_ORGANIZATION/$AZDO_PROJECT/_apis/pipelines/$AZDO_PIPELINE_ID/runs?api-version=$api_version"
    
    # Prepare request body
    # Template parameters example:
    # {
    #     "APPS_TOP": "[one-color]",
    #     "ARGOCD_TARGET_BRANCH": "tmp",
    #     "POSTMAN_BRANCH": "develop",
    #     "TRIGGER_MESSAGE": "p4pa-auth"
    # }
    local request_body=$(cat <<EOF
{
    "templateParameters": $AZDO_TEMPLATE_PARAMETERS,
    "resources": {
        "repositories": {
            "self": {
                "refName": "refs/heads/$AZDO_BRANCH"
            }
        }
    }
}
EOF
)
    
    # Make API call
    log "Chiamata API Azure DevOps in corso..."
    local response=$(curl -s -w "\n%{http_code}" \
        -X POST "$api_url" \
        -H "Authorization: Basic $auth_token" \
        -H "Content-Type: application/json" \
        -d "$request_body")
    
    # Extract status code and response body
    local status_code=$(echo "$response" | tail -n1)
    local response_body=$(echo "$response" | sed '$d')
    
    # Check response
    if [ "$status_code" -eq 200 ]; then
        log "SUCCESS: Pipeline triggerata con successo"
        # Check if jq is available for JSON formatting
        if command -v jq &> /dev/null; then
            echo "$response_body" | jq .
        else
            echo "$response_body"
        fi
    else
        log "ERROR: Errore durante il trigger della pipeline. Status code: $status_code"
        log "Response: $response_body"
        exit 1
    fi
}

# Main script execution
main() {
    log "Avvio script trigger pipeline"
    
    # Check PAT token
    check_pat
    
    # Load template parameters
    load_template_parameters "$1"
    
    # Trigger pipeline
    trigger_pipeline
    
    log "Esecuzione script completata"
}

# Execute main function with first argument
main "$1"
