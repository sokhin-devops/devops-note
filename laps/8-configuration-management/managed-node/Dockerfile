# geerlingguy/docker-ubuntu2404-ansible runs real systemd as PID 1 (via
# --privileged --cgroupns=host and a /sys/fs/cgroup mount — see compose.yaml)
# instead of the usual single-process Docker container. That's what this
# lab needs: the lesson's `service`/`systemd` modules manage real systemd
# units, not a fiction. The image already has Python 3 (Ansible's remote
# requirement); it doesn't have SSH, which the lesson's inventory model
# needs, so that's added here.
FROM geerlingguy/docker-ubuntu2404-ansible:latest

RUN apt-get update \
    && apt-get install -y --no-install-recommends openssh-server sudo \
    && rm -rf /var/lib/apt/lists/* \
    && useradd -m -s /bin/bash ansible \
    && echo "ansible ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/ansible \
    && mkdir -p /home/ansible/.ssh \
    && chmod 700 /home/ansible/.ssh \
    && chown -R ansible:ansible /home/ansible

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
# Inherited from the base image: CMD ["/lib/systemd/systemd"]
