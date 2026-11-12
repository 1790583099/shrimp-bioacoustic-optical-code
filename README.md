# Code release

This package contains the source code of whiteleg shrimp. It is organised as three
independent projects.

| Folder | What it does |
|---|---|
| `bioacoustic/` |  training and evaluation of the five-state acoustic classifier (ASP-SEResNet and comparison models) |
| `optical/` | training and evaluation of the MPA-YOLO detector and comparison detectors |
| `preprocessing/` | MATLAB scripts for band-pass filtering, framing and dual-threshold endpoint detection |

The processed dataset is available on Zenodo:
[Download the dataset](https://doi.org/10.5281/zenodo.24011185).

## 1. Environment

| Item | Version |
|---|---|
| OS | Windows 10 |
| Python | 3.9 |
| PyTorch | 1.12.0 |
| CUDA | 11.7 |
| GPU | NVIDIA GeForce RTX 4060 (8 GB) |

## 2. Bioacoustic classifier (`bioacoustic/`)

Baseline project: `macls` (Apache-2.0), with the SE/ASP pooling head added in this
work.

```
cd bioacoustic
pip install -r requirements.txt
python train.py --configs configs/resnet_se.yml
python eval.py --configs configs/resnet_se.yml
```

Data layout expected by `configs/resnet_se.yml`:

```
dataset/audio/<class>/<clip>.wav     128 kHz, 16-bit, 0.1 s (12,800 samples)
dataset/features_mel2/<class>/*.npy  65 x 128 Mel spectrograms (optional cache)
train_list.txt / test_list.txt       one relative path per line
```

`extract_features.py` rebuilds the cached features. The Mel front end uses
`n_fft = 400`, `hop_length = 200`, `n_mels = 128` and `center = True`, which
turns a 0.1 s clip into a 65 x 128 map.

The train/test lists are not included in the dataset release. Run
`python create_data.py` in `bioacoustic/` to generate `train_list.txt`,
`test_list.txt` and `label_list.txt` before training.

## 3. Optical detector (`optical/`)

Baseline project: Ultralytics YOLO (AGPL-3.0), modified in this work (MAtt
attention modules, MPA-YOLO configuration and Wise-IoU regression loss).

```
cd optical
pip install -e .
python train.py        # ultralytics/cfg/models/MPA-YOLO.yaml, 640 px, 200 epochs
python val.py
python detect.py
```

`data.yaml` points at the image/label folders; edit `path` to your local copy of
the optical subset. 
The modified files relative to upstream Ultralytics are:

- `ultralytics/nn/NewModules/atte.py` - ST, CA and SA attention modules, ATTE and C2fATTE blocks
- `ultralytics/cfg/models/MPA-YOLO.yaml` - MPA-YOLO architecture
- `ultralytics/utils/loss.py` - Wise-IoU v3 regression loss (`bbox_iou(..., WIoU=True)`)
- `train.py` - entry point used in the paper

`train.py` in this release is set to GPU 0; change `CUDA_VISIBLE_DEVICES` if
needed.

## 4. Preprocessing (`preprocessing/`)

MATLAB scripts:

- `main.m` - reads a wav file, applies the elliptic band-pass filter, frames the
  signal and runs the dual-threshold endpoint detector, then saves the accepted
  segments.
- `main2.m` - variant of the detector used for the second annotation pass.

Key parameters (matching Section 3.2 of the paper):

```matlab
fs = 128000;
[b, a] = ellip(5, 0.3, 50, [2000 20000] / (fs / 2), 'bandpass');
frame_size = 960;  frame_shift = 480;
threshold_energy_min = 1e-10;  threshold_energy_max = 2e-4;
threshold_zcr_min = 0.1;       threshold_zcr_max = 0.3;
```

`extract.m` and `Wavelet_Transform.m` in the original working copy were empty
placeholder files and are not included.

## 5. Licences

- `bioacoustic/` is derived from `macls` and keeps its Apache-2.0 licence.
- `optical/` is derived from Ultralytics YOLO and keeps its AGPL-3.0 licence.
  Redistribution and reuse are subject to AGPL-3.0.
- `preprocessing/` is released for academic use.

See `LICENSE_INFO.md` for the list of modifications relative to the upstream
projects.

## 6. Citation

Code repository: https://github.com/1790583099/shrimp-bioacoustic-optical-code
