# WGE Dockerfiles
An easy way to set up a running instance of WGE.

It includes:
- A Postgres container running your database
- An off-target server
- WGE served by Apache and FCGI.

## Requirements
- Docker Engine > v18.06

## Configuring
Create a .env file (just named .env) inside this folder. This will contain the various configurable environment variables.
It must contain the following values:
- SERVER\_EMAIL (a contact emial address)
- APACHE\_PORT (the publicly facing port used to access WGE)
- FCGI\_PORT (an internal port for the FCGI server)
- DB\_USER (the username for the Postgres database)
- DB\_PASS (the password for the Postgres database)
- API\_TRANSPORT (an API key used for https://github.com/htgt/LIMS2-REST-Client)
- OAUTH (needed for the Google OAuth)

Except for OAUTH (see below), you may set these as you please (but they are all required). The ports must be numeric.

## OAuth
We use Google's [OpenID Connect](https://developers.google.com/identity/protocols/oauth2/openid-connect) for the login system. To get the contents of the OAUTH key, use the [Google Developer console](https://console.developers.google.com/apis/credentials), and add an OAuth Client ID. Configure it appropriately. For our public WGE instance, we use:
<dl>
    <dt>Authorized JavaScript origins</dt>
    <dd>https://www.sanger.ac.uk</dd>
    <dt>Authorized redirect URIs</dt>
    <dd>https://wge.stemcell.sanger.ac.uk/set_user</dt>
</dl>
You will need to use appropriate values for your environment.

Download the configuration file and set the OAUTH value to its entire contents. It will contain special characters, including double-quotes, so it will be necessary to wrap it in single quotes.

## Off-target server
The off-target server is configured to download our preprocessed index of the GRCh38 human genome and calculate off-targets on that basis. Please note that indexes on that start at 900,000,001.

To make your own indexes,see our [CRISPR Analyser](https://github.com/htgt/CRISPR-Analyser) project and edit the Dockerfile to edit in your own image.

## Starting the server
The server can be started using the command
```
docker-compose up
```

## Setting up the database
Once the database is running, you need to set up the database.

First, connect to the WGE instance:
```docker exec -it wge-dockerfiles_wge_1 bash```
It is set up with an alias - `wge_psql` to connect to the Postgres server. The schema and some basic data is available in `/home/www/conf/wge/schema.sql`.
```
> docker exec -it wge-dockerfiles_wge_1 bash
$ wge_psql
# begin;
# \i /home/www/conf/wge/schema.sql
# commit;
```

To import a gene list, you can use scripts provided in:
```
/home/www/lib/WGE/bin/get_all_genes.pl --species <name>
/home/www/lib/WGE/bin/load_genes.pl <yaml file>
```

get_all_genes.pl retrieves a list of genes from Ensembl and load_genes.pl populates it into the database. Our most recent import of the gene set, human_genes_98.yaml, is provided in:
```
/home/www/lib/WGE/human_genes_98.yaml
```

To create a list of CRISPRs you will need to use our [CRISPR Analyser](https://github.com/htgt/CRISPR-Analyser) and then copy them in using psql's \copy command:
```
\copy crisprs_grch38(chr_name, chr_start, seq, pam_right, species_id) from '~/GRCh38_crisprs.csv' with delimiter ',';
```

## License
WGE and wge-dockerfiles are licensed under the GNU Affero General Public License v3.0.

The CRISPR Analyser is licensed under the MIT License.

PostgreSQL is licensed under the PostgreSQL License.
