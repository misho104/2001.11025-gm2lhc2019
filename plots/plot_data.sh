#!/bin/sh

wolframscript -script plot_data.wls ../spectrum/x050/tab1_*.slha
mv plot_data_masses.pdf plot_data_tab1_x050.pdf
mv plot_data_cfactors.pdf plot_data_tab1_x050_cfactors.pdf

