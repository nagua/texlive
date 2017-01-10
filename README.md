texlive
===============

## Build

    docker build --rm -t onohr/texlive .

## Basic use

Link to the current working directory in order to run latex commands on files therein. Specify the desired tex commands following the container name, for instance:

    docker run -v $(pwd):/data -it --rm onohr/texlive pdflatex foo.tex
    docker run -v $(pwd):/data -it --rm onohr/texlive

## Linking

Run texlive

    cf) docker run -dP --name tex -v /usr/local/texlive onohr/texlive /bin/sleep 1800

Run the docker container providing the texlive binaries as linked volume. Note that even after the texlive container has been downloaded that this is slow to execute due to the volume linking flag (not really sure why that is).
Once the above task is complete, we can run other containers that may want to make use of a LaTeX environment by linking, such as rocker/rstudio or onohr/pandoc containers:

    cf) docker run --rm -i --volumes-from tex -e PATH=$PATH:/usr/local/texlive/2016/bin/x86_64-linux/ onohr/pandoc foo.md -o output.pdf

    cf) docker run --rm -i --volumes-from tex -e PATH=$PATH:/usr/local/texlive/2016/bin/x86_64-linux/ -v $(pwd):/data onohr/pseqsim /data/deploy.sh
