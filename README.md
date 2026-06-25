![Latest](https://ghcr-badge.egpl.dev/simons-containers/distroless-nodejs/latest_tag?ignore=latest,sha256*&label=latest)  
![Size](https://ghcr-badge.egpl.dev/simons-containers/distroless-nodejs/size?tag=latest)  
![Tags](https://ghcr-badge.egpl.dev/simons-containers/distroless-nodejs/tags?ignore=latest,sha256*)  

# Distroless NodeJS container

Bare-bones distroless NodeJS container image.

## Building

| Build Arg | Description |
|---|---|
| `GCC_VERSION` | Version of gcc to use
| `NODEJS_VERSION` | Version of NodeJS to use

Build container using build-args from versions.yaml:

```bash
docker build -t nodejs $(yq -r 'to_entries | .[] | "--build-arg \(.key | ascii_upcase)_VERSION=\(.value)"' versions.yaml) -f Containerfile .
```

## License

Repository contents (e.g., `Containerfile`, build scripts, and configuration) are licensed under the **MIT License**.

Software included in built container images (such as **NodeJS**, **gcc**, etc...) are provided under their respective upstream licenses and are not covered by the MIT license for this repository.

## Acknowledgements

This project depends on several upstream components that provide essential runtime libraries, toolchains, and platform capabilities:

- **NodeJS** – Node.js is an open-source, cross-platform JavaScript runtime environment.  
  https://nodejs.org

- **GCC** – The GNU Compiler Collection, providing the C and C++ toolchain used to build core system components and application code.  
  https://gcc.gnu.org/
