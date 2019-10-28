function jekyll() {
  case $* in
    serve ) command docker run -p 4000:4000 -v $(pwd):/site bretfisher/jekyll-serve ;;
    * ) command docker run -p 4000:4000 -v $(pwd):/site bretfisher/jekyll $@ ;;
  esac
}
