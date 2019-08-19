## kubectl-check

![docker hub](https://img.shields.io/docker/pulls/lework/kubectl-check.svg?style=flat-square)
![docker hub](https://img.shields.io/docker/stars/lework/kubectl-check.svg?style=flat-square)
[![](https://images.microbadger.com/badges/image/lework/kubectl-check.svg)](http://microbadger.com/images/lework/kubectl-check "Get your own image badge on microbadger.com")
[![](https://images.microbadger.com/badges/version/lework/kubectl-check.svg)](http://microbadger.com/images/lework/kubectl-check "Get your own version badge on microbadger.com")

用于检查deployment的更新状态的kubectl插件



## 插件使用

**安装插件**

```bash
wget -O /usr/local/bin/kubectl-check https://raw.githubusercontent.com/lework/kubectl-check/master/kubectl-check
chmod +x /usr/local/bin/kubectl-check
```

**查看帮助**

```bash
kubectl check -h
```

**检查deployment状态**

> 呈轮询式检查deployment的状态，如果检查到deployment的所有pod`启动成功`并`就绪后`后检查脚本则退出,状态码返回0; 如果检查超过默认次数(60)后还未成功则超时退出，返回状态码1.

```bash
kubectl check -d deploy-name # 指定deploy名称
kubectl check -n default -d deploy-name -v # 指定命名空间
kubectl check -d deploy-name -i 5 -t 10 # 指定检查等待时间时间(单位秒)和检查次数
kubectl check -d deploy-name -v # 打印详细信息
```

## Docker使用

**使用kubeconfig**

```bash
KUBERNETES_KUBECONFIG=$(base64 -w 0 ~/.kube/config)
docker run --rm -e KUBERNETES_KUBECONFIG=$KUBERNETES_KUBECONFIG lework/kubectl-check:latest kubectl check -d deploy-name
```

**使用kube token**

```bash
kubectl create serviceaccount def-ns-admin -n default
kubectl create rolebinding def-ns-admin --clusterrole=admin --serviceaccount=default:def-ns-admin

KUBERNETES_SERVER="https://192.168.77.130:6443"
KUBERNETES_TOKEN=$(kubectl get secret $(kubectl get sa def-ns-admin -o jsonpath={.secrets[].name}) -o jsonpath={.data.token})
KUBERNETES_CERT=$(kubectl get secret $(kubectl get sa def-ns-admin -o jsonpath={.secrets[].name}) -o "jsonpath={.data.ca\.crt}")

docker run --rm -e KUBERNETES_SERVER=$KUBERNETES_SERVER -e KUBERNETES_TOKEN=$KUBERNETES_TOKEN -e KUBERNETES_CERT=$KUBERNETES_CERT lework/kubectl-check:latest kubectl check -d deploy-name
```
