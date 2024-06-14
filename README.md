![CrowdStrike](https://raw.githubusercontent.com/CrowdStrike/falcon-integration-gateway/main/docs/assets/cs-logo.png)

# falcon-integration-gateway [![Python Lint](https://github.com/CrowdStrike/falcon-integration-gateway/actions/workflows/linting.yml/badge.svg)](https://github.com/CrowdStrike/falcon-integration-gateway/actions/workflows/linting.yml) [![Container Build on Quay](https://quay.io/repository/crowdstrike/falcon-integration-gateway/status "Docker Repository on Quay")](https://quay.io/repository/crowdstrike/falcon-integration-gateway)

Falcon Integration Gateway (FIG) forwards threat detection findings and audit events from the CrowdStrike Falcon platform to the [backend](fig/backends) of your choice.

Detection findings and audit events generated by CrowdStrike Falcon platform inform you about suspicious files and behaviors in your environment. You will see detections on a range of activities from the presence of a bad file (indicator of compromise (IOC)) to a nuanced collection of suspicious behaviors (indicator of attack (IOA)) occurring on one of your hosts or containers. You can learn more about the individual detections in [Falcon documentation](https://falcon.crowdstrike.com/support/documentation/40/mitre-based-falcon-detections-framework).

This project facilitates the export of the individual detections and audit events from CrowdStrike Falcon to third-party security dashboards (so called backends). The export is useful in cases where security operation team workflows are tied to given third-party solution to get early real-time heads-up about malicious activities or unusual user activities detected by CrowdStrike Falcon platform.

## API Scopes

API clients are granted one or more API scopes. Scopes allow access to specific CrowdStrike APIs and describe the actions that an API client can perform.

> [!NOTE]
> For more information on how to generate an API client, refer to the [CrowdStrike API documentation](https://falcon.crowdstrike.com/login/?unilogin=true&next=/documentation/page/a2a7fc0e/crowdstrike-oauth2-based-apis#mf8226da).

FIG requires the following API scopes at a minimum:

- **Event streams**: [Read]
- **Hosts**: [Read]

> Consult the backend guides for additional API scopes that may be required.

## Authentication

FIG requires the authentication of an API client ID and client secret, along with its associated cloud region, to establish a connection with the CrowdStrike API.

FIG supports auto-discovery of the Falcon cloud region. If you do not specify a cloud region, FIG will attempt to auto-discover the cloud region based on the API client ID and client secret provided.

> [!IMPORTANT]
> Auto-discovery is only available for [us-1, us-2, eu-1] regions.

### Direct Configuration

> [!NOTE]
> This method is not recommended for production deployments.

You can use the `config.ini` file to store your API client ID and client secret. The `config.ini` file should be located in the `config` directory. To configure authentication, add the following to the `config.ini` file:

```ini
[falcon]
cloud_region = us-1
client_id = YOUR_CLIENT_ID
client_secret = YOUR_CLIENT_SECRET
```

### Environment Variables

You can also provide your API client ID and client secret as environment variables. To do so, set the following environment variables:

```bash
export FALCON_CLOUD_REGION=us-1
export FALCON_CLIENT_ID=YOUR_CLIENT_ID
export FALCON_CLIENT_SECRET=YOUR_CLIENT_SECRET
```

### Credential Store

You can use a credential store to securely store your API client ID and client secret. FIG supports the following credential stores:

- AWS Secrets Manager (`secrets_manager`)
- AWS SSM Parameter Store (`ssm`)

> [!NOTE]
> You can use either direct configuration or environment variables to specify the credential store and its associated configurations.

To configure FIG to use a credential store, add the following to the `config.ini` file:

```ini
[falcon]
cloud_region = us-1

[credentials_store]
#store = ssm|secrets_manager
```

After selecting a credential store, you must provide the necessary configuration for the store. For example, to use AWS Secrets Manager, add the following to the `config.ini` file:

```ini
[secrets_manager]
region = YOUR_AWS_REGION
secrets_manager_secret_name = your/secret/name
secrets_manager_client_id_key = client_id_key_name
secrets_manager_client_secret_key = client_secret_key_name
```

## Configuration

Please refer to the [config.ini](./config/config.ini) file for more details on the available options along with their respective environment variables.

## Backends w/ Available Deployment Guide(s)

| Backend | Description | Deployment Guide(s) | General Guide(s) |
|:--------|:------------|:--------------------|:-------------------|
| AWS | Pushes events to AWS Security Hub | <ul><li>[Manual Deployment](docs/aws/manual/README.md)</li></ul> | [AWS backend](fig/backends/aws) |
| AWS_SQS | Pushes events to AWS SQS | *Coming Soon* | [AWS SQS backend](fig/backends/aws_sqs) |
| Azure | Pushes events to Azure Log Analytics | <ul><li>[Deployment to AKS](docs/aks)</li></ul> | [Azure backend](fig/backends/azure) |
| Chronicle | Pushes events to Google Chronicle | <ul><li>[Deployment to GKE](docs/listings/gke-chronicle/UserGuide.md) (using [marketplace](https://console.cloud.google.com/marketplace/product/crowdstrike-saas/falcon-integration-gateway-chronicle))</li><li>[Deployment to GKE](docs/chronicle) (manual)</li></ul> | [Chronicle backend](fig/backends/chronicle) |
| CloudTrail Lake | Pushes events to AWS CloudTrail Lake | <ul><li>[Deployment to EKS](docs/cloudtrail-lake/eks)</li><li>[Manual Deployment](docs/cloudtrail-lake/manual)</li></ul> | [CloudTrail Lake backend](fig/backends/cloudtrail_lake) |
| GCP | Pushes events to GCP Security Command Center | <ul><li>[Deployment to GKE](docs/listings/gke/UserGuide.md) (using [marketplace](https://console.cloud.google.com/marketplace/product/crowdstrike-saas/falcon-integration-gateway-scc))</li><li>[Deployment to GKE](docs/gke) (manual)</li></ul> | [GCP backend](fig/backends/gcp) |
| Workspace ONE | Pushes events to VMware Workspace ONE Intelligence | *Coming Soon* | [Workspace ONE backend](fig/backends/workspaceone) |
| Generic | Displays events to STDOUT (useful for dev/debugging) | N/A | [Generic Backend](fig/backends/generic) |

## Alternative Deployment Options

> :exclamation: Prior to any deployment, ensure you refer to the [configuration options](./config/config.ini) available to the application :exclamation:

### Installation to Kubernetes using the helm chart

Please refer to the [FIG helm chart documentation](https://github.com/CrowdStrike/falcon-helm/tree/main/helm-charts/falcon-integration-gateway) for detailed instructions on deploying the FIG via helm chart for your respective backend(s).

### With Docker/Podman

To install as a container:

1. Pull the image

    ```bash
    docker pull quay.io/crowdstrike/falcon-integration-gateway:latest
    ```

1. Run the application in the background passing in your backend [CONFIG](./config/config.ini) options as environment variables

    ```bash
    docker run -d --rm \
      -e FALCON_CLIENT_ID="$FALCON_CLIENT_ID" \
      -e FALCON_CLIENT_SECRET="$FALCON_CLIENT_SECRET" \
      -e FALCON_CLOUD_REGION="us-1" \
      -e FIG_BACKENDS=<BACKEND> \
      -e CONFIG_OPTION=CONFIG_OPTION_VALUE \
      quay.io/crowdstrike/falcon-integration-gateway:latest
    ```

1. Confirm deployment

    ```bash
    docker logs <container>
    ```

### From Git Repository

> [!NOTE]
> This method requires Python 3.7 or higher and a python package manager such as `pip` to be installed on your system.

1. Clone and navigate to the repository

    ```bash
    git clone https://github.com/CrowdStrike/falcon-integration-gateway.git
    cd falcon-integration-gateway
    ```

1. Install the python dependencies.

    ```bash
    pip3 install -r requirements.txt
    ```

1. Modify the `./config/config.ini` file with your configuration options or set the associated environment variables.

1. Run the application

    ```bash
    python3 -m fig
    ```

### Updating the FIG from the Git Repository

Depending on which configuration method you are using, follow the steps below to update the FIG from the Git repository.

#### config.ini

If you have made any changes to the `config.ini` file, you can update the FIG by following these steps:

1. Make a backup of the `config/config.ini` file.
1. Remove the `falcon-integration-gateway` directory.
1. Clone and navigate to the repository again.
1. Install/update the python dependencies.
1. Update the `config/config.ini` file with your configuration settings.
    > [!NOTE]
    > Because the `config.ini` file may have new changes (ie, new sections or options), it is recommended to reapply your configuration settings from the backup to the new `config.ini` file.
1. Run the application.

An example of the process:

```bash
cp config/config.ini /tmp/config.ini
cd .. && rm -rf falcon-integration-gateway
git clone https://github.com/CrowdStrike/falcon-integration-gateway.git
cd falcon-integration-gateway
pip3 install --upgrade -r requirements.txt
# Review the new config.ini file and reapply your settings from the backup
python3 -m fig
```

This method ensures that your configuration settings are preserved while updating the FIG to the latest version.

#### Environment Variables (only)

If you are only using environment variables to configure the FIG, you can update the FIG by following these steps:

1. Pull the latest changes from the repository.
1. Install/update the python dependencies.
1. Run the application.

An example of the process:

```bash
git pull
pip3 install --upgrade -r requirements.txt
python3 -m fig
```

## [Developers Guide](./docs/developer_guide.md)

## Statement of Support

Falcon Integration Gateway (FIG) is a community-driven, open source project designed to forward threat detection findings and audit events from the CrowdStrike Falcon platform to the backend of your choice. While not a formal CrowdStrike product, FIG is maintained by CrowdStrike and supported in partnership with the open source community.
