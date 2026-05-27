import sys
import seaborn
import pandas as pd

file = sys.argv[1]

df = pd.read_csv(file, sep='\t', names=['group', 'type', 'read', 'meth_pct'])
df_filtered = df[df['group'] != 'none']

seaborn.set(rc={'figure.figsize':(19,19)})
seaborn.set(style = 'whitegrid')
seaborn.set(font_scale=2.0)
plot = seaborn.violinplot(x=df_filtered['group'], y=df_filtered['meth_pct'], data=df_filtered, linewidth=0.5, inner='point', cut=0)
plot.set_xticklabels(plot.get_xticklabels(), rotation=45)

filename = file.split(".")[0]
plot.figure.savefig(filename+".output.png")
