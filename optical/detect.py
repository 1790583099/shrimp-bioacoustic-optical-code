import warnings

warnings.filterwarnings('ignore')
from ultralytics import YOLO

if __name__ == '__main__':
    model = YOLO('runs/detect/train-yolov5m-无权重-500epoch-16batch/weights/best.pt')
    model.predict(source='dara-test/images',
                  imgsz=640,
                  device='0',
                  )

