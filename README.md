
This repository provides Docker images for working with CARLA, including runtime and development environments for UE4 and UE5.

## Docker Images Overview

### Runtime Images
Docker images tailored for running CARLA packages are available. These images are designed for users who only need to execute CARLA packages without additional development or customization.

### Development Images
Development Docker images are provided for Unreal Engine 4 (UE4) and Unreal Engine 5 (UE5). These images are ideal for developers working on CARLA.

## Available Images

The following Docker images are currently provided:

- **Runtime Images**:
  - `carla-runtime:18.04`
  - `carla-runtime:20.04`
  - `carla-runtime:22.04`

- **Development Images**:
  - `carla-development:ue4-22.04`
  - `carla-development:ue5-22.04`

## Usage

To facilitate the use of these images, a `compose.yaml` file is provided.

#### Run an Image
```bash
docker compose run --rm <IMAGE_NAME>
```
Replace `<IMAGE_NAME>` with the desired image, such as `carla-runtime:20.04`.

#### Join a Running Container
```bash
docker compose exec <IMAGE_NAME> bash
```

### Environment Variables
Some environment variables must be set to use the Docker images:

#### Runtime Images
- `CARLA_ROOT`: Specifies the root path of the CARLA package.
  
  Example:
  ```bash
  CARLA_ROOT="/path/to/carla/package" docker compose run --rm carla-runtime:22.04
  ```

#### Development Images
- `UE5_ROOT`: Path to the source code of the Unreal Engine 5 CARLA fork.
- `CARLA_UE5_ROOT`: Path to the CARLA source code for UE5.
- `UE4_ROOT`: Path to the source code of the Unreal Engine 4 CARLA fork.
- `CARLA_UE4_ROOT`: Path to the CARLA source code for UE4.

> [!IMPORTANT]  
All environment variables must be set before running any Docker image.

> [!IMPORTANT]  
Before running the containers, edit the `compose.yml` file to update the environment variabled for `HOST_UID` and `HOST_GID` with your local host user UID and GID. These variables ensure proper file permissions between your host and the container.
