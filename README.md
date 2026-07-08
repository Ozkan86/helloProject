# ASP.NET Core MVC CI/CD Pipeline with GitHub Actions (Self-Hosted Runner)

Bu proje, **ASP.NET Core MVC** uygulaması üzerinde **GitHub Actions** kullanılarak oluşturulmuş örnek bir **CI/CD Pipeline** çalışmasını göstermektedir.

Projede;

- GitHub Actions
- Self-Hosted Runner
- WSL2 (Ubuntu)
- Manual Approval
- Blue-Green Deployment
- Health Check
- Automatic Rollback

özellikleri uygulanmıştır.

---

# Kullanılan Teknolojiler

- ASP.NET Core MVC (.NET 8)
- GitHub Actions
- GitHub Self Hosted Runner
- Ubuntu (WSL2)
- systemd
- Bash Script
- Git & GitHub

---

# Proje Yapısı

```
helloProject
│
├── Controllers
├── Models
├── Views
├── wwwroot
├── deploy.sh
├── Program.cs
├── helloApp.csproj
└── .github
    └── workflows
        └── dotnet.yml
```

---

# CI/CD Süreci

Pipeline aşağıdaki sırayla çalışmaktadır.

```
Developer

↓

Git Push

↓

Restore

↓

Build

↓

Test

↓

Publish

↓

Artifact Upload

↓

Approval

↓

Artifact Download

↓

Deploy

↓

Restart Service

↓

Health Check

↓

Rollback (Gerekirse)
```

---

# Kurulum

## 1) GitHub Repository Oluşturma

Proje GitHub Repository'sine yüklendi.

```
git init

git add .

git commit -m "Initial Commit"

git push
```

---

# 2) GitHub Actions Workflow Oluşturma

Repository içerisine

```
.github
    workflows
        dotnet.yml
```

dosyası oluşturuldu.

Workflow içerisinde aşağıdaki işlemler tanımlandı.

- Restore
- Build
- Test
- Publish

---

# 3) WSL Kurulumu

Windows üzerinde

```
Windows Subsystem for Linux (WSL2)
```

aktif edildi.

Ardından Ubuntu kuruldu.

Kontrol

```
wsl --status
```

Ubuntu sürümü kontrol edildi.

---

# 4) Ubuntu Güncellemesi

```
sudo apt update

sudo apt upgrade
```

---

# 5) Git Kurulumu

```
git --version
```

ile doğrulandı.

---

# 6) .NET SDK Kurulumu

Ubuntu içerisine .NET SDK kuruldu.

Kontrol

```
dotnet --info
```

---

# 7) Self Hosted Runner Kurulumu

Ubuntu içerisinde

```
/home/zkan/actions-runner
```

klasörü oluşturuldu.

GitHub Repository

```
Settings

↓

Actions

↓

Runners

↓

New Self Hosted Runner
```

adımları takip edilerek verilen komutlar çalıştırıldı.

Runner yapılandırıldı.

```
./config.sh
```

Daha sonra

```
./run.sh
```

ile çalıştırıldı.

Başarılı çalıştığında

```
Listening for Jobs
```

çıktısı görüldü.

---

# 8) Runner'ın Servis Olarak Çalıştırılması

Runner sürekli açık kalabilmesi için service olarak kuruldu.

```
sudo ./svc.sh install

sudo ./svc.sh start
```

Kontrol

```
sudo ./svc.sh status
```

---

# 9) CI Pipeline

Her Push işleminde aşağıdaki adımlar otomatik çalışmaktadır.

## Restore

NuGet paketleri yüklenmektedir.

```
dotnet restore
```

---

## Build

Proje derlenmektedir.

```
dotnet build
```

---

## Test

Varsa Unit Test projeleri çalıştırılmaktadır.

```
dotnet test
```

---

## Publish

Yayınlanabilir dosyalar oluşturulmaktadır.

```
dotnet publish
```

---

## Upload Artifact

Publish çıktısı GitHub Artifact olarak saklanmaktadır.

---

# 10) Production Approval

GitHub Repository içerisinde

```
Settings

↓

Environments

↓

production
```

ortamı oluşturuldu.

Bu ortam için

```
Required Reviewer
```

eklendi.

Böylece Build tamamlandıktan sonra Deploy işlemi otomatik başlamaz.

GitHub üzerinde

```
Approve and Deploy
```

butonuna basılması gerekir.

Bu yapı Production ortamlarında yanlış kodun canlıya çıkmasını engeller.

---

# 11) Blue-Green Deployment

Sunucu üzerinde aşağıdaki klasör yapısı oluşturuldu.

```
/home/zkan/apps

└── helloProject

    ├── blue

    ├── green

    └── current
```

Burada

```
blue
```

ve

```
green
```

aynı uygulamanın iki farklı sürümünü temsil etmektedir.

```
current
```

isimli symbolic link aktif çalışan sürümü göstermektedir.

Deploy sırasında çalışan klasör üzerine yazılmaz.

Yeni sürüm aktif olmayan klasöre kopyalanır.

Ardından

```
current
```

yeni klasöre yönlendirilir.

Bu yöntem sayesinde dosya silinmeden sürüm değiştirilebilmektedir.

---

# 12) Deploy Script

Deploy işlemleri

```
deploy.sh
```

dosyası içerisine taşındı.

Script;

- aktif sürümü belirler
- hedef klasörü seçer
- publish dosyalarını kopyalar
- current linkini değiştirir
- servisi yeniden başlatır
- health check gerçekleştirir

işlemlerini yapmaktadır.

---

# 13) systemd Service

ASP.NET Core uygulaması

```
helloapp.service
```

olarak çalıştırılmaktadır.

Başlatma

```
sudo systemctl start helloapp
```

Durdurma

```
sudo systemctl stop helloapp
```

Yeniden Başlatma

```
sudo systemctl restart helloapp
```

Durum

```
sudo systemctl status helloapp
```

---

# 14) Health Check

Deploy tamamlandıktan sonra

```
curl http://localhost:5000
```

ile uygulamanın başarılı şekilde ayağa kalktığı doğrulanmaktadır.

---

# 15) Automatic Rollback

Health Check başarısız olursa;

```
current
```

eski sürüme yönlendirilir.

Ardından

```
systemctl restart
```

çalıştırılarak önceki çalışan sürüme otomatik geri dönülür.

Böylece hatalı sürüm Production ortamında kalmaz.

---

# Workflow Özeti

```
Developer

↓

Commit

↓

Push

↓

GitHub Actions

↓

Restore

↓

Build

↓

Test

↓

Publish

↓

Artifact

↓

Approval

↓

Deploy

↓

Blue-Green Switch

↓

Restart Service

↓

Health Check

↓

Success

veya

Rollback
```

---

# Kazanımlar

Bu proje ile aşağıdaki DevOps konuları uygulamalı olarak öğrenilmiştir.

- GitHub Actions
- CI/CD Pipeline
- Self Hosted Runner
- WSL2
- Ubuntu
- systemd
- GitHub Environments
- Manual Approval
- Artifact Management
- Blue-Green Deployment
- Health Check
- Automatic Rollback
- Bash Script ile Deployment
- ASP.NET Core Deployment

---

# Not

Bu proje eğitim amacıyla hazırlanmıştır. Amaç, gerçek yazılım şirketlerinde kullanılan CI/CD süreçlerinin temel mantığını küçük ölçekli bir ASP.NET Core MVC uygulaması üzerinde uygulamalı olarak göstermektir.
