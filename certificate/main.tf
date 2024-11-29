# https://yandex.cloud/ru/docs/dns/operations/zone-create-public
resource "yandex_dns_zone" "domain-zone" {
  name = "domain-zone"
  zone = "${var.domain-zone}."
  public = true
}

# https://yandex.cloud/ru/docs/certificate-manager/tf-ref
resource "yandex_cm_certificate" "cert-domain" {
  name    = "cert-domain"
  domains = [var.domain]

  managed {
    challenge_type  = "DNS_CNAME"
    challenge_count = 1 # "example.com" and "*.example.com" has the same DNS_CNAME challenge
  }
}

# Прописываем DNS запись для прохождения челленджа
resource "yandex_dns_recordset" "validation-record" {
  count   = yandex_cm_certificate.cert-domain.managed[0].challenge_count
  zone_id = yandex_dns_zone.domain-zone.id
  name    = yandex_cm_certificate.cert-domain.challenges[count.index].dns_name
  type    = yandex_cm_certificate.cert-domain.challenges[count.index].dns_type
  data    = [yandex_cm_certificate.cert-domain.challenges[count.index].dns_value]
  ttl     = 60
}

data "yandex_cm_certificate" "cert-domain" {
    depends_on = [ yandex_dns_recordset.validation-record ]
    certificate_id = yandex_cm_certificate.cert-domain.id
    wait_validation = true
}

output "cert_id" {
    description = "Certificate ID"
    value = data.yandex_cm_certificate.cert-domain.id
}
