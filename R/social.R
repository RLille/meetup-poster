library(chromote)
library(callr)

social <- function(input, output, rmd_params, chrome_path) {
  callr::r(
    func = function(input, output, rmd_params, chrome_path) {
      web_browser <- suppressMessages(try(chromote::ChromoteSession$new(), silent = TRUE))

      if (
        inherits(web_browser, "try-error") &&
        missing(chrome_path) &&
        Sys.info()[["sysname"]] == "Windows"
      ) {
        edge_path <- "C:/Program Files (x86)/Microsoft/Edge/Application/msedge.exe"
        if (file.exists(edge_path)) {
          Sys.setenv(CHROMOTE_CHROME = edge_path)
          web_browser <- chromote::ChromoteSession$new()
        } else {
          stop('Please set Sys.setenv(CHROMOTE_CHROME = "Path/To/Chrome")')
        }
      }

      xaringan_poster <-  rmarkdown::render(
        input = input,
        output_dir = tempdir(),
        encoding = "UTF-8",
        params = rmd_params
      )

      file.copy(
        from = xaringan_poster,
        to = file.path("ads", sub("\\.png$", ".html", basename(output))),
        overwrite = TRUE
      )

      web_browser$Page$navigate(xaringan_poster, wait_ = FALSE)
      page_browser <- web_browser$Page$loadEventFired()
      out <- web_browser$screenshot(
        filename = output,
        selector = "div.remark-slide-scaler",
        scale = 2
      )
      web_browser$close()
      out
    },
    args = list(
      input = input,
      output = output,
      rmd_params = rmd_params
    )
  )
}
