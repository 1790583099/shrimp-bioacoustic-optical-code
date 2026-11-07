from ultralytics import YOLO
import os

os.environ['CUDA_VISIBLE_DEVICES'] = '0'

if __name__ == '__main__':
    model = YOLO(r'ultralytics\cfg\models\MPA-YOLO.yaml')  # 此处以 m 为例，只需写yolov11m即可定位到m模型
    # model.load('yolov5n.pt')
    model.train(data=r'data.yaml',
                imgsz=640,
                epochs=200,
                single_cls=False,
                batch=16,
                workers=0,
                device='0',
                )
