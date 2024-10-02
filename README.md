# Dockerfile for Laravel 11 Prod (ish)
It seems hard to find a docker setup for Laravel which does not spilt out nginx from php-fpm. This is a simple setup which uses the official php-fpm image and adds nginx to it.
It is not a full production setup but it is a good starting point. The aim is to have just one container for deployments where it's a single container.
