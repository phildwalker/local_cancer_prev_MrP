all: render publish

render:
	Rscript -e 'rmarkdown::render_site()'

encrypt:
	bash encrypt.sh

move:
	mv ./docs/index_encrypted.html ./docs/index.html
	
	
publish:	
	RSCRIPT -e 'fs::dir_copy("docs", new_path = "\\\\mccbiweb2\\AnalyticsHub\\analysis\\cancer-alight", overwrite = T)'