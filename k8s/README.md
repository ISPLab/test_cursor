# Kubernetes Deployment Guide

## Предварительные требования

1. Установленный Kubernetes кластер (например, Minikube для локальной разработки)

3. kubectl - инструмент командной строки для Kubernetes
4. Docker
#docker
установить docker desktop для mac и 
export PATH="$PATH:/Applications/Docker.app/Contents/Resources/bin


## Структура проекта 

```bash
k8s/
├── configmap.yaml    # Конфигурация nginx
├── secret.yaml       # Секретные данные (JWT)
├── backend.yaml      # Деплоймент и сервис для бэкенда
├── frontend.yaml     # Деплоймент и сервис для фронтенда
├── ingress.yaml      # Конфигурация Ingress
└── deploy.sh         # Скрипт деплоя
```

## Подготовка к деплою

1. Сборка Docker образов:
```bash
# В директории backend
docker build -t backend:latest .

# В директории frontend
docker build -t frontend:latest .
```

2. Для Minikube, загрузите образы в локальный registry:
```bash
minikube image load backend:latest
minikube image load frontend:latest
```

## Деплой приложения

1. Перейдите в директорию k8s:
```bash
cd k8s
```

2. Сделайте скрипт deploy.sh исполняемым:
```bash
chmod +x deploy.sh  
```

3. Запустите деплой:
```bash
./deploy.sh
``` 

4. Проверьте статус развертывания:
```bash
kubectl get all -n app-namespace
```

## Полезные команды

```bash
# Перезапуск деплоймента
kubectl rollout restart deployment/backend-deployment -n app-namespace

# Масштабирование
kubectl scale deployment/frontend-deployment --replicas=3 -n app-namespace

# Просмотр событий
kubectl get events -n app-namespace


```         

### Ошибка GUEST_PROVISION при запуске Minikube
Если вы получаете ошибку "GUEST_PROVISION: error provisioning guest", попробуйте следующие шаги:

1. Очистите все ресурсы Minikube:
```bash
minikube delete --all --purge
```

2. Убедитесь, что виртуализация включена в BIOS

3. Для Windows пользователей:
   - Убедитесь, что Hyper-V или WSL2 установлены и включены
   - Запустите PowerShell от имени администратора и выполните:
```powershell
bcdedit /set hypervisorlaunchtype auto
```

4. Попробуйте запустить с явным указанием драйвера:
```bash
# Для Windows с Hyper-V
minikube start --driver=hyperv

# Для Windows с WSL2
minikube start --driver=docker

# Для Linux
minikube start --driver=docker

# Альтернативный вариант с VirtualBox
minikube start --driver=virtualbox
```

5. Если проблема persist, проверьте системные требования:
   - Минимум 2 CPU
   - Минимум 2GB свободной RAM
   - Минимум 20GB свободного места на диске

### Ошибка PROVIDER_DOCKER_NOT_FOUND

#### Для Linux
// ... existing code ...

#### Для macOS
1. Установите Docker Desktop для Mac:
   - Скачайте Docker Desktop с официального сайта: https://www.docker.com/products/docker-desktop
   - Или установите через Homebrew:
```bash
brew install --cask docker
```

2. Запустите Docker Desktop:
   - Найдите Docker Desktop в папке Applications и запустите
   - Или через терминал:
```bash
open -a Docker
```

3. Дождитесь, пока иконка Docker в строке меню перестанет анимироваться (это означает, что Docker запущен)

4. Проверьте установку в терминале:
```bash
docker --version
docker ps
```

5. Если команды docker недоступны в терминале:
   - Перезапустите терминал
   - Или добавьте в ~/.zshrc (для zsh) или ~/.bash_profile (для bash):
```bash
export PATH="$PATH:/Applications/Docker.app/Contents/Resources/bin"
```

Примечание: Для работы Docker Desktop на M1/M2 Mac убедитесь, что у вас установлена версия для Apple Silicon.

### Ошибка DRV_UNSUPPORTED_OS для macOS
Если вы получаете ошибку "The driver 'docker' is not supported on darwin/amd64", используйте альтернативный драйвер:

1. Установите hyperkit:
```bash
brew install hyperkit
```

2. Удалите существующий кластер Minikube:
```bash
minikube delete
```

3. Запустите Minikube с драйвером hyperkit:
```bash
minikube start --driver=hyperkit
```

Альтернативные варианты:

1. Использование VirtualBox (если предпочтительнее):
```bash
# Установка VirtualBox
brew install --cask virtualbox
# Запуск с драйвером virtualbox
minikube start --driver=virtualbox
```

2. Установка драйвера по умолчанию:
```bash
minikube config set driver hyperkit
```

Примечание: Для Apple Silicon (M1/M2) Mac рекомендуется использовать драйвер hyperkit или docker.

## Установка Kubernetes (Minikube)

### Установка для macOS

1. Установите Homebrew (если еще не установлен):
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

2. Установите kubectl:
```bash
brew install kubectl
```

3. Установите Minikube:
```bash
brew install minikube
```

4. Проверьте установку:
```bash
kubectl version
minikube version
```

### Установка kubectl для macOS

1. С помощью Homebrew:
```bash
brew install kubectl
```

2. Проверка установки:
```bash
kubectl version --client
```

3. Альтернативный способ установки (без Homebrew):
```bash
# Загрузка последней версии
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/darwin/amd64/kubectl"

# Сделать файл исполняемым
chmod +x ./kubectl

# Переместить в директорию из PATH
sudo mv ./kubectl /usr/local/bin/kubectl
```

4. Для Apple Silicon (M1/M2):
```bash
# Загрузка arm64 версии
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/darwin/arm64/kubectl"
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl
```

5. Настройка автодополнения (опционально):

Для Zsh:
```bash
# Добавьте в ~/.zshrc
source <(kubectl completion zsh)
```

Для Bash:
```bash
# Добавьте в ~/.bash_profile
source <(kubectl completion bash)
```

6. Проверка конфигурации:
```bash
kubectl config view
```

### Установка для Linux (Ubuntu/Debian)

1. Установите kubectl:
```bash
# Добавьте ключ и репозиторий Kubernetes
curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-archive-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Установите kubectl
sudo apt update
sudo apt install -y kubectl
```

2. Установите Minikube:
```bash
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
```

### Установка для Windows

1. Установите kubectl:
```powershell
# С помощью chocolatey
choco install kubernetes-cli

# Или скачайте напрямую
curl -LO "https://dl.k8s.io/release/v1.28.0/bin/windows/amd64/kubectl.exe"
```

2. Установите Minikube:
   - Скачайте установщик с официального сайта: https://minikube.sigs.k8s.io/docs/start/
   - Или используйте chocolatey:
```powershell
choco install minikube
```

### Запуск и проверка кластера

1. Запустите Minikube (выберите подходящий драйвер):
```bash
# Для macOS
minikube start --driver=hyperkit

# Для Linux
minikube start --driver=docker

# Для Windows
minikube start --driver=hyperv
```

2. Проверьте статус кластера:
```bash
minikube status
kubectl cluster-info
```

3. Проверьте работу узлов:
```bash
kubectl get nodes
```

### Полезные команды

```bash
# Остановить кластер
minikube stop

# Удалить кластер
minikube delete

# Открыть dashboard
minikube dashboard

# Получить IP адрес кластера
minikube ip

# Просмотр логов
minikube logs
```

### Требования к системе

- CPU: минимум 2 ядра
- RAM: минимум 2GB свободной памяти
- Диск: минимум 20GB свободного места
- Интернет-соединение для загрузки компонентов
- Поддержка виртуализации в BIOS/UEFI

```         


### Установка Minikube

1. Для macOS (с помощью Homebrew):
```bash 
brew install minikube
```

2. Для Linux (Ubuntu/Debian):
```bash
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
```




💡  To pull new external images, you may need to configure a proxy: https://minikube.sigs.k8s.io/docs/reference/networking/proxy/
  Done! kubectl is now configured to use "minikube" cluster and "default" namespace by default




  ## Доступ к приложению в Minikube

### Метод 1: Через minikube service

1. Проверьте доступные сервисы:
```bash
kubectl get services
```

2. Откройте доступ к сервису:
```bash
# Замените frontend на имя вашего сервиса
minikube service frontend --url
```

3. Или сразу откройте в браузере:
```bash
minikube service frontend
```

### Метод 2: Через Port Forwarding

1. Проверьте поды:
```bash
kubectl get pods
```

2. Настройте проброс портов:
```bash
# Формат: kubectl port-forward service/имя-сервиса локальный-порт:порт-в-кластере
kubectl port-forward service/frontend 4200:80
```

### Метод 3: Через Ingress

1. Включите Ingress в Minikube:
```bash
minikube addons enable ingress
```

2. Проверьте статус Ingress:
```bash
kubectl get ingress
```

3. Добавьте запись в /etc/hosts:
```bash
# Получите IP Minikube
minikube ip

# Добавьте в /etc/hosts:
# <minikube-ip> your-app.local
```

### Проверка доступности

1. Проверьте статус подов:
```bash
kubectl get pods
kubectl describe pod <имя-пода>
```

2. Проверьте логи:
```bash
kubectl logs <имя-пода>
```

3. Проверьте сервисы:
```bash
kubectl get services
kubectl describe service frontend
```

### Полезные команды для диагностики

```bash
# Получить все ресурсы в namespace
kubectl get all

# Подробная информация о поде
kubectl describe pod <имя-пода>

# Интерактивный shell в поде
kubectl exec -it <имя-пода> -- /bin/bash

# Просмотр логов в реальном времени
kubectl logs -f <имя-пода>

# Проверка конфигурации Ingress
kubectl get ingress
kubectl describe ingress
```

### Устранение проблем

1. Если сервис недоступен:
   - Проверьте статус подов (`kubectl get pods`)
   - Проверьте логи (`kubectl logs`)
   - Убедитесь, что сервис правильно настроен (`kubectl describe service`)

2. Если приложение не отвечает:
   - Проверьте, что поды в статусе Running
   - Проверьте endpoints сервиса
   - Проверьте настройки портов в сервисе и deployment




   Добавлены health check эндпоинты
Улучшены проверки готовности и живучести
Добавлены CORS настройки в Ingress
Улучшен скрипт деплоя
Добавлены ресурсные лимиты
Улучшена обработка ошибок


kubectl create secret docker-registry regcred \
  --docker-server=<your-registry-server> \
  --docker-username=<your-name> \
  --docker-password=<your-password>




Правильно настроены права для nginx в контейнере:
Созданы все необходимые директории
Установлены корректные права доступа
Nginx работает от непривилегированного пользователя
Корректно настроен Pod в Kubernetes:
Добавлен securityContext с правильными UID/GID
Настроены необходимые тома для работы nginx
Используются emptyDir для временных файлов
Все сервисы доступны:
Frontend на http://localhost:8080
Backend API на http://localhost:3000
Настроен проброс портов
Теперь приложение должно работать стабильно и безопасно. Если понадобятся какие-то изменения или возникнут вопросы - обращайтесь!
