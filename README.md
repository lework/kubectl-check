## kubectl-check

![docker hub](https://img.shields.io/docker/pulls/lework/kubectl-check.svg?style=flat-square)
![docker hub](https://img.shields.io/docker/stars/lework/kubectl-check.svg?style=flat-square)
[![](https://images.microbadger.com/badges/image/lework/kubectl-check.svg)](http://microbadger.com/images/lework/kubectl-check "Get your own image badge on microbadger.com")
[![](https://images.microbadger.com/badges/version/lework/kubectl-check.svg)](http://microbadger.com/images/lework/kubectl-check "Get your own version badge on microbadger.com")

用于检查deployment的所有pod是否**就绪**的kubectl插件



## 插件使用

**所需权限**

```bash
# 创建rabc权限
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: ci-deploy
  namespace: default

---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: Role
metadata:
  name: ci-deploy
  namespace: default
rules:
  - apiGroups: ["apps", "extensions", ""]
    resources: ["pods", "deployments", "deployments/scale", "services", "replicasets"]
    verbs: ["create","get","list","patch","update"]

---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: RoleBinding
metadata:
  name: ci-deploy
  namespace: default
subjects:
  - kind: ServiceAccount
    name: ci-deploy
roleRef:
  kind: Role
  name: ci-deploy
  apiGroup: rbac.authorization.k8s.io
EOF
```

**安装依赖**
```bash
wget -O /usr/local/bin/jq https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64
chmod +x /usr/local/bin/jq
```

**安装插件**

```bash
wget -O /usr/local/bin/kubectl-check https://raw.githubusercontent.com/lework/kubectl-check/master/kubectl-check
chmod +x /usr/local/bin/kubectl-check
```

**查看帮助**

```bash
kubectl check -h
Check if all pods in Kubernetes deployment are ready.

Usage: /usr/local/bin/kubectl-check [options]

Options:
  -c,--kubeconfig    Specify kubeconfig, default is /root/.kube/config
  -n,--namespace     Specify namespace, default is default
  -d,--deployment    Depoyment name
  -s,--statefulset   StatefulSet name
  -i,--interval      Check the deployment status interval
  -t,--total         Total number of inspections
  -sn,--success      Total number of success
  -v,--verbose       Verbose info
  --nocolor          Do not output color
  -h,--help          View help
```

**检查deployment状态**

> 呈轮询式检查deployment的状态，如果检查到deployment的所有pod`启动成功`并`就绪后`后检查脚本则退出,状态码返回0; 如果检查超过默认次数(60)后还未成功则超时退出，返回状态码1.

```bash
kubectl check -d deploy-name # 指定deploy名称
kubectl check -d deploy-name -c /root/.kube/config-test # 指定 kubeconfig 文件
kubectl check -n default -d deploy-name -v # 指定命名空间
kubectl check -d deploy-name -i 5 -t 10 # 指定检查等待时间时间(单位秒)和检查次数
kubectl check -d deploy-name -v # 打印详细信息
```

## Docker使用

**使用kubeconfig**

```bash
# 设定kubeconfig
KUBERNETES_KUBECONFIG=$(base64 -w 0 ~/.kube/config)

# 执行cmd命令
docker run --rm -e KUBERNETES_KUBECONFIG=$KUBERNETES_KUBECONFIG lework/kubectl-check:latest kubectl check -d deploy-name

# 以变量的形式指定deploy name
docker run --rm -e KUBERNETES_KUBECONFIG=$KUBERNETES_KUBECONFIG -e KUBERNETES_DEPLOY=deploy-name lework/kubectl-check:latest
```

**使用kube token**

```bash
KUBERNETES_SERVER="https://192.168.77.130:6443"
KUBERNETES_TOKEN=$(kubectl get secret $(kubectl get sa ci-deploy -o jsonpath={.secrets[].name}) -o jsonpath={.data.token})
KUBERNETES_CERT=$(kubectl get secret $(kubectl get sa ci-deploy -o jsonpath={.secrets[].name}) -o "jsonpath={.data.ca\.crt}")

# 执行cmd命令
docker run --rm -e KUBERNETES_SERVER=$KUBERNETES_SERVER -e KUBERNETES_TOKEN=$KUBERNETES_TOKEN -e KUBERNETES_CERT=$KUBERNETES_CERT lework/kubectl-check:latest kubectl check -d deploy-name

# 以变量的形式指定deploy name
docker run --rm -e KUBERNETES_SERVER=$KUBERNETES_SERVER -e KUBERNETES_TOKEN=$KUBERNETES_TOKEN -e KUBERNETES_CERT=$KUBERNETES_CERT -e KUBERNETES_DEPLOY=deploy-name lework/kubectl-check:latest
```
