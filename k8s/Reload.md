# Перезапуск кластера Kubernetes

## 1. Остановка текущего кластера
```bash
# Остановить все сервисы
kubectl delete all --all -n app-namespace

# Удалить namespace
kubectl delete namespace app-namespace

# Остановить minikube
minikube stop

# Удалить кластер
minikube delete
```

## 2. Создание нового кластера
```bash
# Запустить новый кластер
minikube start

# Включить необходимые аддоны
minikube addons enable ingress
```

## 3. Сборка и загрузка Docker образов
```bash
# Собрать образ бэкенда
cd backend
docker build -t backend:latest .

# Собрать образ фронтенда
cd ../frontend
docker build -t frontend:latest .

# Загрузить образы в minikube
minikube image load backend:latest
minikube image load frontend:latest
```

## 4. Деплой приложения
```bash
# Перейти в директорию k8s
cd ../k8s

# Запустить скрипт деплоя
./deploy.sh
```

## 5. Проверка статуса
```bash
# Проверить все ресурсы
kubectl get all -n app-namespace

# Проверить ingress
kubectl get ingress -n app-namespace

# Проверить логи подов
kubectl logs -f -n app-namespace deployment/backend-deployment
kubectl logs -f -n app-namespace deployment/frontend-deployment
```

## 6. Настройка локального доступа
```bash
# Получить IP minikube и добавить в /etc/hosts
echo "$(minikube ip) app.local" | sudo tee -a /etc/hosts
```

После выполнения всех шагов приложение будет доступно по адресу: http://app.local

## Полезные команды для диагностики

```bash
# Проверка статуса minikube
minikube status

# Просмотр всех подов
kubectl get pods -n app-namespace

# Детальная информация о поде
kubectl describe pod <pod-name> -n app-namespace

# Просмотр логов в реальном времени
kubectl logs -f <pod-name> -n app-namespace

# Проверка сервисов
kubectl get services -n app-namespace

# Проверка конфигурации ingress
kubectl describe ingress -n app-namespace
```

## Устранение проблем

1. Если образы не загружаются:
```bash
# Проверить список образов в minikube
minikube image list
```

2. Если поды не запускаются:
```bash
# Проверить события в namespace
kubectl get events -n app-namespace
```

3. Если ingress не работает:
```bash
# Проверить статус ingress контроллера
kubectl get pods -n ingress-nginx
```

4. Для проверки сетевой доступности:
```bash
# Проброс портов для тестирования
kubectl port-forward service/frontend-service 8080:80 -n app-namespace
```
