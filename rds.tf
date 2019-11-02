resource "aws_db_subnet_group" "mysql-subnet" {
    name = "mysql-subnet"
    description = "MYSQL subnet group"
    subnet_ids = ["${aws_subnet.private_subnet_1.id}","${aws_subnet.private_subnet_2.id}", "${aws_subnet.private_subnet_3.id}"]
}

resource "aws_db_parameter_group" "mysql-parameters" {
    name = "mysql-parameters"
    family = "mysql5.7"
    description = "MySQL parameter group"

#    parameter {
#      # Tweaking to do
#   }

}


resource "aws_db_instance" "mysql-master" {
  allocated_storage    = 5
  engine               = "mysql"
  engine_version       = "5.7.26"
  instance_class       = "db.${var.INSTANCE_TYPE}"    
  identifier           = "mysqlmaster"
  name                 = "mysqlmaster"
  username             = "root"
  password             = "${var.RDS_PSWD}"
  db_subnet_group_name = "${aws_db_subnet_group.mysql-subnet.name}"
  parameter_group_name = "${aws_db_parameter_group.mysql-parameters.name}"
  multi_az             = "false" # to avoid costs
  vpc_security_group_ids = ["${aws_security_group.rds_sg.id}"]
  storage_type         = "gp2"
  backup_retention_period = 30
  availability_zone = "${aws_subnet.private_subnet_1.availability_zone}" 
  skip_final_snapshot = "true"
  tags = {
      Name = "mysql_master_instance"
  }
}

resource "aws_db_instance" "mysql-slave-1" {
  instance_class = "db.${var.INSTANCE_TYPE}"
  identifier = "mysqlslave-1"
  replicate_source_db = "${aws_db_instance.mysql-master.identifier}"
  availability_zone = "${aws_subnet.private_subnet_1.availability_zone}"
  skip_final_snapshot = "true"
  tags = {
    Name = "mysql_slave-1"
  }
}

resource "aws_db_instance" "mysql-slave-2" {
  identifier = "mysqlslave-2"
  instance_class = "db.${var.INSTANCE_TYPE}"
  replicate_source_db = "${aws_db_instance.mysql-master.identifier}"
  availability_zone = "${aws_subnet.private_subnet_2.availability_zone}"
  skip_final_snapshot = "true"
  tags = {
    Name = "mysql_slave-2"
  }
}

resource "aws_db_instance" "mysql-slave-3" {
  identifier = "mysqlslave-3"
  instance_class = "db.${var.INSTANCE_TYPE}"
  replicate_source_db = "${aws_db_instance.mysql-master.identifier}"
  availability_zone = "${aws_subnet.private_subnet_3.availability_zone}"
  skip_final_snapshot = "true"
  tags = {
    Name = "mysql_slave-3"
  }
}