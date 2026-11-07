# Licence and provenance notes

## bioacoustic/

Derived from the open-source `macls` project (Apache License 2.0). The original
licence file is kept as `bioacoustic/LICENSE`.

Modifications made for this work:

- added `macls/models/resnet_se.py` (ResNet backbone with squeeze-and-excitation
  blocks and attentional statistics pooling);
- added the SE and ASP pooling implementations used by the ablation rows in
  Table 3;
- added the configuration files under `configs/`;
- added the data preparation and feature extraction scripts.

## optical/

Derived from Ultralytics YOLO (GNU Affero General Public License v3.0). The
original licence file is kept as `optical/LICENSE`. Because the project is
distributed under AGPL-3.0, any redistribution or network use of this code is
subject to the same licence.

Modifications made for this work:

- `ultralytics/nn/NewModules/atte.py`: ST, CA and SA attention modules plus the
  ATTE and C2fATTE blocks;
- `ultralytics/cfg/models/MPA-YOLO.yaml`: detector configuration;
- `ultralytics/utils/loss.py`: Wise-IoU v3 bounding-box regression loss;
- `train.py`: training entry point (single GPU, 200 epochs, batch 16).

## preprocessing/

MATLAB scripts written for this project. No third-party code is included.

## Data

The dataset is released under CC BY 4.0 (see the Zenodo record). It is not
covered by the code licences above.
