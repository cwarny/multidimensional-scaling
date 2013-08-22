DataPoint[] dataPoints;
int colCount;
int rowCount;
float[][] targetDist;
float[][] actualDist;
PVector[] gradients;
float rate = 0.00001;
float totalError;
float lastError = MAX_FLOAT;

void setup() {
  size(1280, 720);
  loadData("economicmilitaryaid.csv");
  targetDist = new float[rowCount][rowCount];
  actualDist = new float[rowCount][rowCount];
  gradients = new PVector[rowCount];
  calcTargetDist();
  setupGradients();
  fill(255);
}

void draw() {
  background(0);
  calcActualDist();
  totalError = 0;
  calcGradients();
  println("last error: " + lastError);
  println("total error: " + totalError);
  if (lastError != MAX_FLOAT && lastError <= totalError) {
    noLoop();
  }
  lastError = totalError;
  
  for (int i=0; i<rowCount; i++) {
    dataPoints[i].update(gradients[i], rate);
    dataPoints[i].render();
  }
}

void loadData(String url) {
  Table myTable = loadTable(url);
  myTable.removeTitleRow();
  colCount = myTable.getColumnCount();
  rowCount = myTable.getRowCount();
  dataPoints = new DataPoint[rowCount];
  for (int i=0; i<rowCount; i++) {
    DataPoint dp = new DataPoint(colCount);
    for (int j=1; j<colCount; j++) {
      dp.data[j] = myTable.getFloat(i,j);
    }
    dp.label = myTable.getString(i,0);
    println(dp.label);
    dataPoints[i] = dp;
  }
  actualDist = new float[rowCount][rowCount];
}

void calcTargetDist() {
  for (int i=0; i<rowCount; i++) {
    for (int j=0; j<rowCount; j++) {
      println(pearson(dataPoints[i].data, dataPoints[j].data));
      targetDist[i][j] = map(pearson(dataPoints[i].data, dataPoints[j].data), -1, 1, height, 1);
    }
  }
}

void setupGradients() {
  for (int i=0; i<rowCount; i++) {
    gradients[i] = new PVector(0.0,0.0);
  }
}

void calcActualDist() {
  for (int i=0; i<rowCount; i++) {
    for (int j=0; j<rowCount; j++) {
      actualDist[i][j] = PVector.dist(dataPoints[i].pos, dataPoints[j].pos);
    }
  }
}

void calcGradients() {
  for (int i=0; i<rowCount; i++) {
    for (int j=0; j<rowCount; j++) {
      if (i == j) continue;
      float errorTerm = (actualDist[i][j] - targetDist[i][j]) / targetDist[i][j];
      gradients[i].x += ((dataPoints[i].pos.x - dataPoints[j].pos.x) / actualDist[i][j]) * errorTerm;
      gradients[i].y += ((dataPoints[i].pos.y - dataPoints[j].pos.y) / actualDist[i][j]) * errorTerm;
      totalError += abs(errorTerm);
    }
  }
}

float tanimoto(float[] v1, float[] v2) {
  float c1 = 0;
  float c2 = 0;
  float shr = 0;
  
  for (int i=0; i<v1.length; i++) {
    if (v1[i] != 0) c1++;
    if (v2[i] != 0) c2++;
    if (v1[i] != 0 && v2[i] != 0) shr++;
  }
  
  return 1.0-shr/(c1+c2-shr);
}

float pearson(float[] v1, float[] v2) {
  float sum1 = 0;
  float sum1Sq = 0;
  float sum2 = 0;
  float sum2Sq = 0;
  float pSum = 0;
  for (int i=0; i<v1.length; i++) {
    sum1 += v1[i];
    sum2 += v2[i];
    sum1Sq += pow(v1[i],2);
    sum2Sq += pow(v2[i],2);
    pSum += v1[i] * v2[i];
  }
  
  float num = pSum - (sum1 * sum2 / v1.length);
  float den = sqrt((sum1Sq - pow(sum1,2) / v1.length) * (sum2Sq - pow(sum2,2) / v1.length));
  
  if (den == 0) {
    return 0;
  } else {
    return num/den;
  }
}

void keyPressed() {
  if (key == 's') {
    saveFrame("out/frames####.png");
  }
}
