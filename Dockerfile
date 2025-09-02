#@follow_tag(registry-proxy.engineering.redhat.com/rh-osbs/openshift-golang-builder:rhel_9_golang_1.24)
FROM brew.registry.redhat.io/rh-osbs/openshift-golang-builder:v1.24.4-202507171054.g2f6f49f.el9 AS builder

# Start Konflux-specific steps
ENV ART_BUILD_ENGINE=konflux
ENV ART_BUILD_DEPS_METHOD=cachi2
ENV ART_BUILD_NETWORK=open
ENV ART_BUILD_DEPS_MODE=default
USER 0
RUN mkdir -p /tmp/art/yum_temp; mv /etc/yum.repos.d/*.repo /tmp/art/yum_temp/ || true
COPY .oit/art-unsigned.repo /etc/yum.repos.d/
RUN curl https://certs.corp.redhat.com/certs/Current-IT-Root-CAs.pem
ADD https://certs.corp.redhat.com/certs/Current-IT-Root-CAs.pem /tmp/art
# End Konflux-specific steps
ENV __doozer=update BUILD_RELEASE=202509022053.p2.g3396e28.assembly.test.el9 BUILD_VERSION=v4.20.0 OS_GIT_MAJOR=4 OS_GIT_MINOR=20 OS_GIT_PATCH=0 OS_GIT_TREE_STATE=clean OS_GIT_VERSION=4.20.0-202509022053.p2.g3396e28.assembly.test.el9 SOURCE_GIT_TREE_STATE=clean __doozer_group=openshift-4.20 __doozer_key=oadp __doozer_uuid_tag=oadp-v4.20.0-20250902.205358 __doozer_version=v4.20.0 
ENV __doozer=merge OS_GIT_COMMIT=3396e28 OS_GIT_VERSION=4.20.0-202509022053.p2.g3396e28.assembly.test.el9-3396e28 SOURCE_DATE_EPOCH=1756384322 SOURCE_GIT_COMMIT=3396e283b156defedd56443099c61ba197eb7504 SOURCE_GIT_TAG=3396e28 SOURCE_GIT_URL=https://github.com/migtools/konflux-build-data 
COPY . /workspace
WORKDIR /workspace/oadp-operator/
ENV GOEXPERIMENT strictfipsruntime
RUN CGO_ENABLED=1 GOOS=linux go build -mod=mod -a -tags strictfipsruntime -o /workspace/oadp-operator/bin/manager main.go

#@follow_tag(registry.redhat.io/ubi9/ubi-minimal:latest)
FROM quay.io/redhat-user-workloads/ocp-art-tenant/art-images@sha256:a39d1e6a613429c9db25cd37b104c431f6eb368ac905fc6564e39b3f65bf1d1d

# Start Konflux-specific steps
ENV ART_BUILD_ENGINE=konflux
ENV ART_BUILD_DEPS_METHOD=cachi2
ENV ART_BUILD_NETWORK=open
ENV ART_BUILD_DEPS_MODE=default
USER 0
RUN mkdir -p /tmp/art/yum_temp; mv /etc/yum.repos.d/*.repo /tmp/art/yum_temp/ || true
COPY .oit/art-unsigned.repo /etc/yum.repos.d/
RUN curl https://certs.corp.redhat.com/certs/Current-IT-Root-CAs.pem
ADD https://certs.corp.redhat.com/certs/Current-IT-Root-CAs.pem /tmp/art
# End Konflux-specific steps
ENV __doozer=update BUILD_RELEASE=202509022053.p2.g3396e28.assembly.test.el9 BUILD_VERSION=v4.20.0 OS_GIT_MAJOR=4 OS_GIT_MINOR=20 OS_GIT_PATCH=0 OS_GIT_TREE_STATE=clean OS_GIT_VERSION=4.20.0-202509022053.p2.g3396e28.assembly.test.el9 SOURCE_GIT_TREE_STATE=clean __doozer_group=openshift-4.20 __doozer_key=oadp __doozer_uuid_tag=oadp-v4.20.0-20250902.205358 __doozer_version=v4.20.0 
ENV __doozer=merge OS_GIT_COMMIT=3396e28 OS_GIT_VERSION=4.20.0-202509022053.p2.g3396e28.assembly.test.el9-3396e28 SOURCE_DATE_EPOCH=1756384322 SOURCE_GIT_COMMIT=3396e283b156defedd56443099c61ba197eb7504 SOURCE_GIT_TAG=3396e28 SOURCE_GIT_URL=https://github.com/migtools/konflux-build-data 
RUN microdnf -y install openssl && microdnf -y reinstall tzdata && microdnf clean all
WORKDIR /
COPY --from=builder /workspace/oadp-operator/bin/manager .
COPY oadp-operator/LICENSE /licenses/
USER 65532:65532
ENTRYPOINT ["/manager"]

# Start Konflux-specific steps
USER 0
RUN rm -f /etc/yum.repos.d/art-* && mv /tmp/art/yum_temp/* /etc/yum.repos.d/ || true
RUN rm -rf /tmp/art
USER 65532:65532
# End Konflux-specific steps

LABEL \
        name="migtools/oadp" \
        vendor="Red Hat, Inc." \
        com.redhat.component="oadp-operator-container" \
        io.openshift.maintainer.project="OCPBUGS" \
        io.openshift.maintainer.component="Unknown" \
        version="v4.20.0" \
        release="202509022053.p2.g3396e28.assembly.test.el9" \
        io.openshift.build.commit.id="3396e283b156defedd56443099c61ba197eb7504" \
        io.openshift.build.source-location="https://github.com/migtools/konflux-build-data" \
        io.openshift.build.commit.url="https://github.com/migtools/konflux-build-data/commit/3396e283b156defedd56443099c61ba197eb7504" \
        io.k8s.description="Empty" \
        io.k8s.display-name="Empty" \
        io.openshift.tags="Empty" \
        description="Empty" \
        summary="Empty"

