library(shiny)
library(ggplot2)
library(RCurl)
library(caret)

shinyServer(function(input, output) {
  url<-getURL('https://archive.ics.uci.edu/ml/machine-learning-databases/auto-mpg/auto-mpg.data')
  
  carData<-read.table(textConnection(url), colClasses=c(replicate(8, 'numeric'), 'character'), na.strings = '?')
  colnames(carData)<-c('mpg', 'cylinders', 'displacement', 'horsepower', 'weight','acceleration',
                       'model_year', 'origin', 'car_name')
  
  carData<-carData[complete.cases(carData),]
  carData$cylinders<-as.factor(carData$cylinders)
  carData$model_year<-as.factor(carData$model_year)
  
  data1<-reactiveValues()
  
  data1$clicked<-FALSE
  
  fitmodel<-observeEvent(input$submit, {
    fields<-c('mpg')
    
    print(data1)
    if (input$ch_cylinder){
      if (input$cylinders!='7'){
        data1$errorCyl<-0
        fields<-rbind(fields,'cylinders')
        newcar$cylinders<-as.factor(input$cylinders)
      }
      if (input$cylinders=='7'){
        data1$errorCyl<-1
      }
    }
    if (input$ch_displacement){
      fields<-rbind(fields,'displacement')
      newcar$displacement<-as.numeric(input$displacement)
    }
    if (input$ch_horsepower){
      fields<-rbind(fields,'horsepower')
      newcar$horsepower<-as.numeric(input$horsepower)
    }
    if (input$ch_weight){
      fields<-rbind(fields,'weight')
      newcar$weight<-as.numeric(input$weight)
    }
    if (input$ch_acceleration){
      fields<-rbind(fields,'acceleration')
      newcar$acceleration<-as.numeric(input$acceleration)
    }
    if (input$ch_model_year){
      fields<-rbind(fields,'model_year')
      newcar$model_year<-as.factor(input$model_year)
    }
    
    carData<-carData[,fields]
    fields<-fields[-1]
    newcar<-newcar[,fields]
    set.seed(333)
    inTrain<-createDataPartition(carData$mpg,p=0.75, list = F)
    data1$training<-carData[inTrain,]
    data1$testing<-carData[-inTrain,]
    
    data1$model<-lm(log(mpg+1)~.,data = data1$training)
    data1$val.predic<-exp(predict(data1$model, data1$testing))-1
    
    data1$alldata<-data.frame(actual=data1$testing$mpg, predicted=data1$val.predic)
    data1$newcar.pre<-exp(predict(data1$model, newcar, interval='confidence'))-1
    data1$clicked<-TRUE
  })

  output$fitText<-renderPrint({
    if (data1$clicked==TRUE){
      if (data1$errorCyl==1){
        cat('Error: number of cylinders \nhas to be 3, 4, 5, 6 or 8. \nIgnoring cylinders')
        cat('\n')
        cat('\n')
      }
      suModel<-summary(data1$model)
      cat('R squared: ')
      cat(round(suModel$r.squared, 2))
      cat('\nPrediction (mpg): ')
      cat(round(data1$newcar.pre[1],2))
      cat('\nLower limit (mpg): ')
      cat(round(data1$newcar.pre[2],2))
      cat('\nUpper limit (mpg): ')
      cat(round(data1$newcar.pre[3],2))
    }
  })
  
  output$fit <- renderPlot({
    if (data1$clicked==TRUE){
      ggplot(data1$alldata, aes(x=actual, y=predicted))+
        geom_point(alpha=0.5)+
        geom_rect(xmin=-Inf, xmax=Inf, ymin=data1$newcar.pre[2], 
                  ymax=data1$newcar.pre[3], fill='green', alpha=0.003)+
        geom_hline(yintercept =data1$newcar.pre[1], color='green4', size=0.5)+
        geom_abline(intercept = 0, slope = 1, color='red')+
        theme_minimal()+
        xlab('Actual (miles per galon)')+
        ylab('Predicted (miles per galon)')
    }
  })
})
