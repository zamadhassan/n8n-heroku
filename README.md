# n8n on Heroku

[![Deploy to Heroku](https://www.herokucdn.com/deploy/button.svg)](https://dashboard.heroku.com/new?template=https://github.com/YOUR_USERNAME/YOUR_REPO_NAME)

[n8n](https://n8n.io/) is a free and open fair-code licensed node-based Workflow Automation Tool. This repository provides everything needed to deploy n8n on Heroku with PostgreSQL using your GitHub Student Developer Pack credits.

## Prerequisites

- [Heroku account](https://signup.heroku.com/) (with Student Developer Pack verified)
- [GitHub account](https://github.com/)
- [Heroku CLI](https://devcenter.heroku.com/articles/heroku-cli) (optional, for manual deployment)

## Quick Deploy (One-Click)

1. Click the **Deploy to Heroku** button above.
2. Log in to your Heroku dashboard.
3. Fill in the required config vars (see [Environment Variables](#environment-variables)).
4. Click **Deploy App**.
5. After deployment, click **View** to open n8n.

## Manual Deployment

### 1. Fork this repo

Click the **Fork** button on GitHub to create your own copy.

### 2. Create a Heroku app

```bash
heroku login
heroku create <your-app-name> --stack=container
```

### 3. Provision PostgreSQL

```bash
heroku addons:create heroku-postgresql:mini --app <your-app-name>
```

> The `mini` tier is free with Student Developer Pack credits.
> For production, use `standard-0` or higher.

### 4. Set environment variables

```bash
heroku config:set N8N_ENCRYPTION_KEY="$(openssl rand -hex 20)" --app <your-app-name>
heroku config:set WEBHOOK_URL="https://<your-app-name>.herokuapp.com" --app <your-app-name>
heroku config:set N8N_HOST="<your-app-name>.herokuapp.com" --app <your-app-name>
heroku config:set N8N_PROTOCOL=https --app <your-app-name>
heroku config:set NODE_ENV=production --app <your-app-name>
heroku config:set GENERIC_TIMEZONE=UTC --app <your-app-name>
heroku config:set DB_POSTGRESDB_SSL_REJECT_UNAUTHORIZED=false --app <your-app-name>
```

### 5. Deploy

```bash
git push heroku main
```

### 6. Open the app

```bash
heroku open --app <your-app-name>
```

## Environment Variables

| Variable | Required | Description |
|---|---|---|
| `N8N_ENCRYPTION_KEY` | **Yes** | Random 32+ char string to encrypt credentials. Generate with `openssl rand -hex 20`. |
| `WEBHOOK_URL` | **Yes** | Full URL of your app: `https://<app>.herokuapp.com` |
| `N8N_HOST` | **Yes** | Hostname only: `<app>.herokuapp.com` |
| `N8N_PROTOCOL` | **Yes** | Set to `https` |
| `NODE_ENV` | **Yes** | `production` |
| `GENERIC_TIMEZONE` | No | Your timezone (e.g. `America/New_York`). Default: `UTC`. |
| `DB_POSTGRESDB_SSL_REJECT_UNAUTHORIZED` | No | Required for Heroku Postgres SSL. Set to `false`. |

> **Security**: Never commit secrets to GitHub. Use `heroku config:set` for all sensitive values.

## Updating n8n

The `Dockerfile` pulls `n8nio/n8n:latest`, so each time you redeploy, you get the latest version:

```bash
# If connected via Git:
git commit --allow-empty -m "Redeploy n8n"
git push heroku main

# If using Heroku Container Registry:
heroku stack:set container --app <your-app-name>
heroku container:push web --app <your-app-name>
heroku container:release web --app <your-app-name>
```

## Webhook URLs

n8n will display correct webhook URLs based on these config vars:

- `WEBHOOK_URL` sets the base URL shown in the editor.
- `N8N_HOST` and `N8N_PROTOCOL` ensure webhooks resolve to your Heroku domain.

Make sure `WEBHOOK_URL` is set to `https://<your-app-name>.herokuapp.com` **before** creating any webhook workflows.

## Production Checklist

- [ ] `N8N_ENCRYPTION_KEY` is set to a unique random value
- [ ] `WEBHOOK_URL` matches your actual Heroku app URL
- [ ] `N8N_HOST` is set correctly
- [ ] `N8N_PROTOCOL=https`
- [ ] `NODE_ENV=production`
- [ ] PostgreSQL addon is provisioned and linked
- [ ] Automatic deploys are disabled or connected to a private fork

## License

[MIT](LICENSE)
