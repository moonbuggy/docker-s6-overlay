# s6-overlay
Images with statically built [s6-overlay][s6-repo] and
[s6-add-contenv](https://github.com/moonbuggy/docker-s6-add-contenv) inside, for
multiple architectures.

These can be used during multi-stage builds to install s6-overlay into an image.
It's easier than making sure any s6-fetching stages in multi-arch builds are
identical across different projects and relying on `docker build` caching the
layer.

## Usage
```dockerfile
## get s6 overlay
FROM "moonbuggy2000/s6-overlay:${S6_VERSION}-${S6_ARCH}" AS s6-overlay

## build image
FROM "${FROM_IMAGE}"
COPY --from=s6-overlay / /

# .. et cetera ..
```

## Tags
Images are tagged in the form `<s6 version>-<s6 arch>`. Tags including
`-prebuilt-` use binaries from [just-containers/s6-overlay][s6-repo], otherwise
the images contain binaries built from source.

Valid `<s6-arch>`: `aarch64/arm64`, `amd64`, `arm`, `armhf`, `i486/x86`, `i686`,
`mips64le`, `ppc64le`, `riscv64`, `s390x`

## Building
The `./build.sh` script takes arguments in the form
`<s6 version>(-<build type>)(-<s6 arch>)`

A default build, with no arguments, will create images for all possible
architectures containing the s6 overlay and s6 add-contenv files, ready to copy
into another image in a multi-stage build.

#### `<s6 version>`
Specify a version number matching _"v?\[0-9.\]+"_ or `latest`. This will be
matched against tags in the [s6 repo][s6-repo] to automatically determine the
latest full version from a partial version number (i.e. specifying `2` will
build _v2.2.0.3_).

Defaults to `latest` if not specified.

#### `<build type>`
*   _unset_ - an image containing self-built s6 overlay
*   `prebuilt` - an image containing the pre-built s6 overlay from
     [just-containers/s6-overlay][s6-repo]
*   `tarballs` - an image with the s6 overlay files in _*.tar.xz_ archives. The
     tarballs will also be copied into the `builds/<s6 version>` folder on the
     host. s6-add-contenv will **not** be included with tarball images

#### `<s6 arch>`
Available architectures are generally the same as those in the image tags above.
Refer to [arch.yaml](arch.yaml) for more options (some of which may be excluded
by [build.conf](build.conf), depending on the specific build).

All possible architectures will be built if no `<s6 arch>` is specified.

#### Examples
```sh
# latest version on all architectures
./build.sh latest

# specific version(s) on all architectures
./build.sh v3.1.1.2 2.2.0.3

# specific versions and architectures
./build.sh latest-amd64 v2.2.0.3-armhf

# latest version's tarballs on all architectures
./build.sh latest-tarballs

# whatever, really
./build.sh latest-amd64 latest-tarballs-amd64 2.2-armhf v3.0-tarballs 3.0.0

# everything (latest and tarballs for all arch)
./build.sh all

# check for newer source versions
./build.sh check

# build newer versions (latest, prebuilt and tarballs)
./build.sh update
```

## Notes
These haven't been tested on all architectures. The `-prebuilt-` images are less
likely to have issues, but aren't available for as many architectures as we can
build for ourselves.

## Links
GitHub:
*   <https://github.com/moonbuggy/docker-s6-overlay>
*   <https://github.com/moonbuggy/docker-s6-add-contenv>
*   <https://github.com/moonbuggy/docker-base-images>

Docker Hub: <https://hub.docker.com/r/moonbuggy2000/s6-overlay>

[s6-repo]: <https://github.com/just-containers/s6-overlay>
