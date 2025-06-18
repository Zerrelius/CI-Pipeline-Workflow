# CI/CD Pipeline Workflow - React to AWS EC2

Eine vollständige CI/CD Pipeline die eine React App baut, AWS Infrastruktur mit Terraform bereitstellt und die App auf EC2 deployed.

## 🏗️ Architektur

- **Frontend:** React + Vite
- **Infrastructure:** AWS EC2, VPC, Security Groups
- **IaC:** Terraform mit S3 Backend
- **CI/CD:** GitHub Actions
- **Web Server:** Nginx auf Ubuntu

## 🚀 Pipeline Stages

1. **CI Build:** React App bauen und testen
2. **Infrastructure Provision:** AWS Ressourcen mit Terraform erstellen
3. **Application Deploy:** App auf EC2 deployed über SSH

## ⚙️ Setup

### 1. AWS Vorbereitung
- IAM User mit EC2, VPC, S3, DynamoDB Rechten erstellen
- S3 Bucket für Terraform State erstellen
- Access Keys generieren

### 2. GitHub Secrets konfigurieren
```
AWS_ACCESS_KEY_ID = your-access-key
AWS_SECRET_ACCESS_KEY = your-secret-key
AWS_REGION = eu-central-1
TF_STATE_BUCKET = your-terraform-state-bucket
```

### 3. Terraform Backend anpassen
Ersetzen Sie in `terraform/provider.tf` den Bucket-Namen:
```hcl
backend "s3" {
  bucket = "your-bucket-name"  # ← Ihren Bucket-Namen hier
  # ...
}
```

## 🔄 Pipeline ausführen

1. **Automatisch:** Push zu `main` Branch startet Pipeline
2. **Manuell:** GitHub Actions Tab → "Run workflow"

## 🗑️ Infrastruktur zerstören

1. Gehen Sie zu Actions Tab
2. Wählen Sie "Destroy AWS Infrastructure" 
3. Klicken Sie "Run workflow"
4. Geben Sie "DESTROY" ein zur Bestätigung

## 📊 Monitoring

- **Pipeline Status:** GitHub Actions Tab
- **AWS Ressourcen:** AWS Console → EC2/VPC
- **Website:** Nach erfolgreichem Deployment wird die URL angezeigt

## 🔒 Sicherheit

- Alle sensiblen Daten in GitHub Secrets
- SSH Keys werden temporär generiert
- Security Groups beschränken Zugriff
- Terraform State in verschlüsseltem S3 Bucket

## 🛠️ Lokale Entwicklung

```bash
cd frontend
npm install
npm run dev
```

## 📝 Troubleshooting

- **Pipeline Fails:** Prüfen Sie GitHub Actions Logs
- **AWS Permissions:** Stellen Sie sicher, dass IAM User alle nötigen Rechte hat
- **SSH Connection:** Warten Sie bis EC2 Instance vollständig gestartet ist