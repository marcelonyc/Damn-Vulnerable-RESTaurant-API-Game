# Prepare your environment to run this actions

These details apply to the `jfrog-build-linux-sh.yaml` action

## Runners
Change the `runs-on` setting to a runner of your choice. This workflow is set to run on self-hosted runners.

## JFrog setup
1. Create a project 
2. Create and Assign these repository types
    For Each DEV-QA-PROD
    use pattern <project>-<type>-<local/remote>-<stage: dev, qa,prod>
    - DOCKER_REPO: Local Docker repository to store your application image

    Remote repos
    - PYTHON_REMOTE_REPO: Remote Maven repository
    - DOCKER_REMOTE: Remote Docker repository
    - DEBIAN_REMOTE_REPO: Remote Repo for debian artifacts

3. Define the OIDC integration
    For an example of this integration, check this repo: https://github.com/marcelonyc/ga-jfrog-primer


Notes 
- Enable Xray scanning on each repo
- Under Xray Settings -> Indexed Resources -> Builds
    Include a pattern to match your build name Select bbuil By Pattern: `<build name>/**` 
    
    The build name is hardcoded in the action yaml   
        `name: dvr-game-build`


## Github Settings
### Add this variables to the repository

- OIDC_PROVIDER_NAME: As defined in step 3 above
- DOCKER_REPO: As defined in step 2 above (dev repo only)
- DOCKER_REMOTE: As defined in step 2 above 
- PYTHON_REMOTE_REPO: As defined in step 2 above 
- DEBIAN_REMOTE_REPO: As defined in step 2 above 
- IMAGE_NAME: '<IMAGE NAME: your choice>'
- JF_PROJECT: Your project name as define in step one above
- JF_URL: FQDN of your JFrog instance (without https)
- JF_BUILD_NAME: Name your build
