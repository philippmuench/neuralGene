#

## create learning dataset

### specify learning samples

Go to https://www.ncbi.nlm.nih.gov/geo/browse/?view=samples&suppl=CEL&zsort=date&display=20%20> and export the list in`csv` format. Save it as `samples.tsv`.

### load data

load `CEL` gene expression files from NCBI based on `samples.tsv` file

```
./loadcell.sh
```

this script creates also the `data/im2text.json` file and the corresponding `png` written to `data/im2text/`


The `json` file also contains unstructured informations of the downloaded sample which will be used for the learning task

```
RNA Sample of Homo sapiens organism of TF1 with control vector_1
RNA Sample of Homo sapiens organism of TF1 with human PRL3_4
RNA Sample of Homo sapiens organism of cells at day 0, biological rep1"
```

