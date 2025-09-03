#@follow_tag(registry-proxy.engineering.redhat.com/rh-osbs/openshift-golang-builder:rhel_9_golang_1.23)
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
ENV __doozer=update BUILD_RELEASE=202509032154.p2.g2d2cbcc.assembly.test.el9 BUILD_VERSION=v4.20.0 OS_GIT_MAJOR=4 OS_GIT_MINOR=20 OS_GIT_PATCH=0 OS_GIT_TREE_STATE=clean OS_GIT_VERSION=4.20.0-202509032154.p2.g2d2cbcc.assembly.test.el9 SOURCE_GIT_TREE_STATE=clean __doozer_group=openshift-4.20 __doozer_key=oadp __doozer_uuid_tag=oadp-v4.20.0-20250903.215417 __doozer_version=v4.20.0 
ENV __doozer=merge OS_GIT_COMMIT=2d2cbcc OS_GIT_VERSION=4.20.0-202509032154.p2.g2d2cbcc.assembly.test.el9-2d2cbcc SOURCE_DATE_EPOCH=1756935912 SOURCE_GIT_COMMIT=2d2cbcc36ffc18bcd58779315912ca3e5a8897e6 SOURCE_GIT_TAG=2d2cbcc36 SOURCE_GIT_URL=https://github.com/migtools/konflux-build-data 
COPY . /workspace

#######################################################################
#######################################################################
#                                                                     #
#      W     W    AA     RRRR     N   N    III    N   N     GGG       #
#      W     W   A  A    R   R    NN  N     I     NN  N    G          #
#      W  W  W   AAAA    RRRR     N N N     I     N N N    G  GG      #
#       W W W    A  A    R R      N  NN     I     N  NN    G   G      #
#        W W     A  A    R  RR    N   N    III    N   N     GGG       #
#                                                                     #
#  Any changes to the `velero` and `restic` sections below must also  #
#  be reconciled in oadp-mustgather/Dockerfile.in for consistency.    #
#######################################################################
# BEGIN                                                               #
#######################################################################

# velero
WORKDIR /workspace/
ENV GOEXPERIMENT strictfipsruntime
RUN CGO_ENABLED=1 GOOS=linux go build -a -mod=readonly -ldflags '-X github.com/vmware-tanzu/velero/pkg/buildinfo.Version=v1.16.1-OADP' -tags strictfipsruntime -o ./bin/velero ./cmd/velero
RUN CGO_ENABLED=1 GOOS=linux go build -a -mod=readonly -tags strictfipsruntime -o ./bin/velero-restore-helper ./cmd/velero-restore-helper
RUN CGO_ENABLED=1 GOOS=linux go build -a -mod=readonly -tags strictfipsruntime -o ./bin/velero-helper ./cmd/velero-helper

# restic
WORKDIR /workspace/restic/
ENV GOEXPERIMENT strictfipsruntime
RUN CGO_ENABLED=1 GOOS=linux go build -a -mod=readonly -tags strictfipsruntime -o ./bin/restic ./cmd/restic
USER 65534:65534

#######################################################################
# END                                                                 #
#######################################################################

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
ENV __doozer=update BUILD_RELEASE=202509032154.p2.g2d2cbcc.assembly.test.el9 BUILD_VERSION=v4.20.0 OS_GIT_MAJOR=4 OS_GIT_MINOR=20 OS_GIT_PATCH=0 OS_GIT_TREE_STATE=clean OS_GIT_VERSION=4.20.0-202509032154.p2.g2d2cbcc.assembly.test.el9 SOURCE_GIT_TREE_STATE=clean __doozer_group=openshift-4.20 __doozer_key=oadp __doozer_uuid_tag=oadp-v4.20.0-20250903.215417 __doozer_version=v4.20.0 
ENV __doozer=merge OS_GIT_COMMIT=2d2cbcc OS_GIT_VERSION=4.20.0-202509032154.p2.g2d2cbcc.assembly.test.el9-2d2cbcc SOURCE_DATE_EPOCH=1756935912 SOURCE_GIT_COMMIT=2d2cbcc36ffc18bcd58779315912ca3e5a8897e6 SOURCE_GIT_TAG=2d2cbcc36 SOURCE_GIT_URL=https://github.com/migtools/konflux-build-data 
RUN dnf -y reinstall tzdata && dnf clean all
RUN dnf -y install less nmap-ncat openssl && dnf clean all
COPY --from=builder /workspace/bin/velero velero
COPY --from=builder /workspace/bin/velero-restore-helper velero-restore-helper
COPY --from=builder /workspace/bin/velero-helper velero-helper
COPY --from=builder /workspace/restic/bin/restic /usr/bin/restic
COPY LICENSE /licenses/

RUN mkdir -p /home/velero
RUN chmod -R 777 /home/velero

USER 65534:65534
ENV HOME=/home/velero

ENTRYPOINT ["/velero"]


# Start Konflux-specific steps
USER 0
RUN rm -f /etc/yum.repos.d/art-* && mv /tmp/art/yum_temp/* /etc/yum.repos.d/ || true
RUN rm -rf /tmp/art
USER 65534:65534
# End Konflux-specific steps

LABEL \
        name="migtools/oadp" \
        vendor="Red Hat, Inc." \
        com.redhat.component="oadp-operator-container" \
        io.openshift.maintainer.project="OCPBUGS" \
        io.openshift.maintainer.component="Unknown" \
        version="v4.20.0" \
        release="202509032154.p2.g2d2cbcc.assembly.test.el9" \
        io.openshift.build.commit.id="2d2cbcc36ffc18bcd58779315912ca3e5a8897e6" \
        io.openshift.build.source-location="https://github.com/migtools/konflux-build-data" \
        io.openshift.build.commit.url="https://github.com/migtools/konflux-build-data/commit/2d2cbcc36ffc18bcd58779315912ca3e5a8897e6" \
        io.k8s.description="Empty" \
        io.k8s.display-name="Empty" \
        io.openshift.tags="Empty" \
        description="Empty" \
        summary="Empty"

