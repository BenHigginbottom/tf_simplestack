provider "aws" {
  region                  = "${var.aws_region}"
  shared_credentials_file = "/home/ben/.aws/credentials"
}


module "scan" {
  source = "github.com/BenHigginbottom/tf_modules//scan"
}

module "latestAMI" {
  source = "github.com/BenHigginbottom/tf_modules//latestAMI"
  
}

module "ec2" {
  source = "github.com/BenHigginbottom/tf_modules//ec2dist"
  INSTANCES = "2"
  AMI = "${module.latestAMI.ec2linuxd}"
  INSTTYPE = "t2.micro"
  VPCSG = "${module.scan.security_group}"
  //AZ = "${module.scan.names}"
  SUBNETS = "${module.scan.computesubnet}"
}

module "EBS" {
  source = "github.com/BenHigginbottom/tf_modules//EBS"
  Count = "2"
  AvZ = "${module.ec2.AvZ}"
  Size = "5"
  EBSKey =  "${module.scan.ebsenckey}" 
}

module "EBSAttach" {
  source = "github.com/BenHigginbottom/tf_modules//EBSAttach"
  Count = "2"
  VolID = "${module.EBS.volid}"
  InstID = "${module.ec2.ids}"
}

module "ELB" {
  source = "github.com/BenHigginbottom/tf_modules//ELB"
  NAME = "Bens-Test-ELB"
  PORT = "80"
  DESTPORT = "443"
  INSTANCES = ["${module.ec2.ids}"]
  SNET = ["${module.scan.computesubnet}"]
}

module "MariaRDS" {
  source = "github.com/BenHigginbottom/tf_modules//MariaRDS"
  identifier = "developmentdb"
  storageamount = "10"
  instance_class = "db.m3.medium"
  db_name = "IAMDATABASE"
  username = "IAMUSER"
  password = "IAMPASSWORD"
  dbkms = "${module.scan.rdsenckey}"
  dbsnetgroup = "${var.dbsubnetgroup}"
}
