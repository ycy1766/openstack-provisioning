#########################################
# Common Settings
#########################################
variable "project-prefix" {
  description = "Project Prefix"
  default     = "cyyoon-change"
}

variable "groupwareid" {
  default = "cyyoon"
}

variable "token" {
  description = "Openstack keystone token"
  default     = "Change Me"
}

variable "image-id" {
  default = "Change Me"
}

#########################################
# Network Settings
#########################################

variable "internal-network-1-network-addr" {
  default = "10.111.1"
}

variable "internal-network-2-network-addr" {
  default = "10.112.1"
}

variable "internal-network-3-network-addr" {
  default = "10.113.1"
}

variable "external-network-1-network-addr" {
  default = "172.21.1"
}

variable "external-dns-nameserver" {
  type    = list(string)
  default = ["8.8.8.8", "168.126.63.1"]
}

variable "sriov-external-network_id" {
  default = "Change Me"
}

variable "sriov-external-subnet-id" {
  type    = list(string)
  default = ["Change Me"]
}

variable "dmz-ip-addr" {
  default = "Change Me"
}

#########################################
# Instance Flavors
#########################################

variable "deploy-flavor" {
  default = "m1.large"
}

variable "ceph-flavor" {
  default = "m1.large"
}

#########################################
# Instance Info
#########################################

variable "deploy-instance" {
  description = "Value is isntance host ip(ex. 13=> 192.168.1.13)"
  type        = map(string)
  default = {
    deploy-010 = "10"
  }
}

variable "ceph-instance" {
  description = "Value is isntance host ip(ex. 13=> 192.168.1.13)"
  type        = map(string)
  default = {
    ceph-011 = "11"
    ceph-012 = "12"
    ceph-013 = "13"
    ceph-014 = "14"
    ceph-015 = "15"
    ceph-016 = "16"
    ceph-021 = "21"
    ceph-022 = "22"
    ceph-023 = "23"
  }
}

#########################################
# SSH Key
#########################################

variable "keypair-name" {
  default = "cy-ocp"
}

variable "ssh-public-key" {
  type = list(string)
  default = [
    "ssh-rsa Change Me"]
}

variable "ssh-private-key" {
  default = <<EOF
    -----BEGIN OPENSSH PRIVATE KEY-----
    sample-sample-sample-sample-sample-sample-sample-sample-sample
    sample-sample-sample-sample-sample-sample-sample-sample-sample
    sample-sample-sample-sample-sample-sample-sample-sample-sample
    sample-sample-sample-sample-sample-sample-sample-sample-sample
    -----END OPENSSH PRIVATE KEY-----
EOF
}
