# make certonly email=your@gmail.com domain="*.domain.com"
certonly:
	@docker run -it --rm --name certbot \
		-v "./etc:/etc/letsencrypt" \
		-v "./var:/var/lib/letsencrypt" \
		certbot/certbot certonly --manual --agree-tos --preferred-challenges dns -m $(email) -d $(domain)
