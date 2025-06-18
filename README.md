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

___

## Reflexions Fragen

● Beschreibe die Rolle jedes Jobs in deiner Pipeline (ci_build, infra_provision,
app_deploy) und wie die Abhängigkeiten (needs) sicherstellen, dass sie in der
richtigen Reihenfolge ausgeführt werden.
ci_build baut und testet meine Anwendung
infra_provision stellt meine AWS Infrastruktur bereit und oder aktualisiert sie
app_deploy deployet meine Anwendung auf der entsprechend vorher erstellten Infrastruktur
ci_build -> infra_provision -> app_deploay sind so in entsprechender Reihenfolge von einander abhängig.
infra_provision braucht ci_build um sicher zu stellen das der Build erfolgreich deployed werden kann weil er entsprechend getestet wurde
app_deploy braucht infra_provision um entsprechend vorher die Infrastruktur zu garantieren die benötigt wird für den Build

● Wie wurde das Artefakt (Frontend Build) vom CI-Job an den Deployment-Job
übergeben? Warum ist dies notwendig?
Es wurde im Dist Ordner hochgeladen und entsprechend später wieder runtergeladen in Form von Artefakten.
So läuft jeder Job in einer seperaten VM.
Jobs können immer wieder neu durchlaufen werden.
Es ist dadurch persistent und auch vorhanden obwohl ein Job bereits beendet wurde und ein neuer beginnt.
Es ist durch das Artefakt reproduzierbar und kann immer wieder neu auf einem System ausgeführt werden.
Artefakte können außerdem so heruntergeladen und inspiziert werden.

● Wie wurden sensible Daten (AWS Credentials, SSH Private Key) sicher in GitHub
Actions gespeichert und im Workflow genutzt? Warum sind diese Methoden besser
als das Hinterlegen im Code oder in unverschlüsselten Dateien?
Mithilfe von Secrets für die AWS Credentials und einem Dynamischen SSH Key der generiert wird.
Der SSH Key wird zu einem temporären Artefakt.
Die Secrets sind verschlüsselt und entsprechend sicher gespeichert auf GitHub, dadurch nur von Repository-Mitgliedern entsprechend erreichbar.
In den Logs werden die Werte außerdem nur mit *** Gekennzeichnet.
Der dynamische SSH-Key kann somit in einer Pipeline neu generiert werden und nur dann einmal vverwendet werden. Sie existieren nur während des Workflows.

Im Code wären sie unsicher gespeichert, von jedem einsichtbar und könnten daher schnell missbraucht werden.

● Beschreibe den Prozess, wie die Pipeline die öffentliche IP der EC2 Instanz ermittelt und dann das Artefakt dorthin kopiert hat.
Mithilfe von Infra_Provision.
Verwendet wird er dann im app_deploy.
Übertragen wird er mithilfe einer SSH Verbindung.

● Was passiert mit der von Terraform gemanagten Infrastruktur, wenn du einfach
Code in deinem React Projekt änderst und die Pipeline erneut durchläuft (ohne das
Destroy-Workflow auszuführen)?
Terraform vergleicht gewünschten Zustand mit aktuellem State
Erkennt Änderungen an bestehender Infrastruktur
Aktualisiert nur geänderte Ressourcen
Unveränderte Ressourcen bleiben unberührt

● Welche Schritte im Deployment-Prozess (innerhalb des app_deploy Jobs) stellen
sicher, dass die neue Version deiner React App auf der EC2 Instanz sichtbar wird?
Alte Version entfernen:
sudo rm -rf /var/www/ci-pipeline-workflow/*

Neue Dateien installieren:
sudo mv /tmp/* /var/www/ci-pipeline-workflow/
sudo chown -R www-data:www-data /var/www/ci-pipeline-workflow/
sudo chmod -R 755 /var/www/ci-pipeline-workflow/

Webserver neu Laden:
sudo nginx -t  # Konfiguration testen
sudo systemctl reload nginx  # Graceful reload ohne Downtime

Cache-Handling:
Browser-Cache: React Build enthält Hash-basierte Dateinamen
Nginx-Cache: Reload erneuert Server-Cache
CDN-Cache: Würde separate Invalidierung benötigen