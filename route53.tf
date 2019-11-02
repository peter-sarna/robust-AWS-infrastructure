resource "aws_route53_zone" "database" {
  name = "db.domain"
  
  vpc {
    vpc_id = "${aws_vpc.main_vpc.id}"
  }
}

resource "aws_route53_record" "read_1" {
  zone_id = "${aws_route53_zone.database.zone_id}"
  set_identifier = "reader_1"
  name = "read.db.domain"
  type = "CNAME"
  ttl = 5
  records = [ "${aws_db_instance.mysql-slave-1.endpoint}" ]
  health_check_id = "${aws_route53_health_check.reader_check.id}"
  weighted_routing_policy {
    weight = 33
  }
}
 
resource "aws_route53_record" "read_2" {
  zone_id = "${aws_route53_zone.database.zone_id}"
  set_identifier = "reader_2"
  name = "read.db.domain"
  type = "CNAME"
  ttl = 5
  records = [ "${aws_db_instance.mysql-slave-2.endpoint}" ]
  health_check_id = "${aws_route53_health_check.reader_check.id}"
  weighted_routing_policy {
    weight = 33
  }
}

resource "aws_route53_record" "read_3" {
  zone_id = "${aws_route53_zone.database.zone_id}"
  set_identifier = "reader_3"
  name = "read.db.domain"
  type = "CNAME"
  ttl = 5
  records = [ "${aws_db_instance.mysql-slave-3.endpoint}" ]
  health_check_id = "${aws_route53_health_check.reader_check.id}"
  weighted_routing_policy {
    weight = 33
  }
}
# TO DO HEALTH CHECKS

resource "aws_route53_health_check" "reader_check" {
  fqdn = "read.db.domain"
  type = "TCP"
  port = 3306
  failure_threshold = "2"
  request_interval = "30"
}

# source: https://aws.amazon.com/premiumsupport/knowledge-center/requests-rds-read-replicas/
