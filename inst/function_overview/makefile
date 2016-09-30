R=R


.PHONY: all


all: ./createFunctionOverview.Rout




./createFunctionOverview.Rout: createFunctionOverview.R
	$(R) CMD BATCH --no-save --no-restore --no-site-file --no-environ createFunctionOverview.R ./createFunctionOverview.Rout



