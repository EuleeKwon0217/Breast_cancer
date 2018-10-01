install.packages("readxl")
install.packages("dplyr")
install.packages("ggplot2")
install.packages("xlsx")
install.packages("caret")
install.packages("e1071")
install.packages("class")
install.packages("lattice")
install.packages("geometry")
install.packages("gmodels")

library(xlsx)
library(dplyr)
library(lattice)
library(ggplot2)
library(caret)
library(e1071)
library(class)
library(gmodels)

bc <- read.csv("New_breast_cancer.csv",header=T, stringsAsFactors = FALSE)

bc$Class = as.factor(bc$Class)

#bc$Class <- factor(bc$Class, levels =c("recur","no-recur"),labels = c("recurrence-events","no-recurrence-events"))

str(bc)

bc

# set.seed�� ������ ���� �����ϱ� ���� ����ϸ� ���Ŀ��� ���� ������ �������� ���´�.
# ������ �������� ����ؼ� �ޱ�����
set.seed(123)
bc_shuffle <- bc[sample(nrow(bc)), ]

bc_shuffle
# ���� wbcd ������ �����ӿ� id��� �÷��� �ʿ����.
# dataframe���� �÷��� �����ϰ� ����ϴ� ������� 
# �ڵ� �ؼ�: wbcd_shuffle���� 1���÷��� �����ϰ� ������ �÷��� wbcd2�� �Ҵ��Ѵ�.
bc2 <- bc_shuffle[-1]
bc2

# normalize��� ����ȭ�Լ��� ����� ���� �Լ��� �����Ѵ�.
normalize <- function(x) {
  return ( (x-min(x)) / (max(x) - min(x))  )
  }

ncol <- which(colnames(bc2) == "Class")
ncol

# lapply(list or vector,function): function�� ������ ����� ����Ʈ�� ���ϵ�.
# (������ ���� ���̴� �Լ�)
# as.data.frame: dataframe���� ��ȯ�ϴ� �Լ�
# factor�� label�� �����ϰ� normalize�Ѵ�.
bc_n <- as.data.frame(lapply(bc2[-ncol],normalize))
bc_n


# ����ȭ�� data���̺��� ������ label�� �����ش�(SQL���� JOIN�� ���� ����)
bc_n <- cbind(bc2[2], bc_n)


# ���⼭�� 9:1�� ������.
train_num<-round(0.9*nrow(bc_n),0)
bc_train<-bc_n[1:train_num,]
bc_test<-bc_n[(train_num+1):nrow(bc_n),]



# train �����Ϳ� test �������� ���� ���缭 label�� ������.
bc_train_label <- bc2[1:train_num,1]
bc_test_label <- bc2[(train_num+1):nrow(bc_n),1]


# repeats�� �������� ��� max(k)�� ������
repeats = 10
numbers = 10
tunel = 10

# "�����Ͱ� ����Ȯ, �ҿ��� �Ǵ� ���ո��Ѱ� ����� Ȯ���ϱ� ���ؼ� ���Ǵ� ó��"
set.seed(1234)
x = trainControl(method = "repeatedcv",
                 # numbers��ŭ �ɰ��ڴ�. 1���� validation, ������ train �ݺ�
                 number = numbers,
                 # number �ѹ����� repeat = 1
                 repeats = repeats,
                 classProbs = TRUE,
                 summaryFunction = twoClassSummary)

model1 <- train(Class~. , data = bc_train, method = "knn",
                preProcess = c("center","scale"),
                trControl = x,
                metric = "ROC",
                tuneLength = tunel)

# ���� ���� k��
k_n <- max(model1$bestTune)
k_n

#knn �� �Ҷ� ���ڰ��� ������ na/nan/inf in foreign function call ���� �߻�
bc_train$Class <- ifelse(bc_train$Class == "recur", 1,0)
bc_test$Class <- ifelse(bc_test$Class == "recur", 1,0)
bc_train_label$Class <- ifelse(bc_train_label$Class == "recur", 1,0)


# knn �Լ��� �ִ� library
result1 <- knn(train=bc_train, test=bc_test, cl= bc_train_label, k = k_n )
result1
bc_train_label

CrossTable(x= bc_train_label, y= result1, prop.chisq=FALSE)