import sys
import seaborn
import pandas as pd

df = pd.read_csv('read_summary_split_filtered.txt', sep='\t', names=['group', 'read', 'num', 'meth_pct'])
df_filtered = df[df['group'] != 'none']

seaborn.set(rc={'figure.figsize':(19,19)})
seaborn.set(style = 'whitegrid')
seaborn.set(font_scale=2.0)
plot = seaborn.violinplot(x=df_filtered['group'], y=df_filtered['meth_pct'], data=df_filtered, linewidth=0.5, inner='point', cut=0)
plot.set_xticklabels(plot.get_xticklabels(), rotation=45)
plot.figure.savefig("output.png")
