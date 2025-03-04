import os
import json
import logging
import random
import string
from azure.identity import DefaultAzureCredential
from azure.keyvault.secrets import SecretClient
import azure.functions as func

# Configuración del cliente de Key Vault
KEY_VAULT_URI = os.getenv("KEY_VAULT_URI")
SECRET_NAME = "storage-access-key"

credential = DefaultAzureCredential()
client = SecretClient(vault_url=KEY_VAULT_URI, credential=credential)

def generate_secret():
    """Genera una nueva clave aleatoria"""
    return ''.join(random.choices(string.ascii_letters + string.digits, k=32))

def main(req: func.HttpRequest) -> func.HttpResponse:
    logging.info("Solicitud de rotación de secreto recibida.")

    try:
        new_secret = generate_secret()
        client.set_secret(SECRET_NAME, new_secret)
        logging.info("Secreto actualizado exitosamente en Key Vault.")

        return func.HttpResponse(
            json.dumps({"status": "success", "new_secret": new_secret}),
            status_code=200,
            mimetype="application/json"
        )

    except Exception as e:
        logging.error(f"Error al rotar el secreto: {str(e)}")
        return func.HttpResponse(
            json.dumps({"status": "error", "message": str(e)}),
            status_code=500,
            mimetype="application/json"
        )
