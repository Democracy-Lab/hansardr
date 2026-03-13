library(tidyverse)
library(lubridate)

hansard_c19_improved_speaker_names_2 <- read_csv("hansard_c19_improved_speaker_names_2.csv")
  
hansard_c19_improved_speaker_names_2 <- hansard_c19_improved_speaker_names_2 %>%
  mutate(speechdate = as.Date(speechdate))

hansard_c19_improved_speaker_names_2 <- hansard_c19_improved_speaker_names_2 %>%
  select(-X20) %>%
  rename(suggested_speaker = new_speaker)


filter_to_decade <- function(df, decade) {
  df %>%
    filter(year(speechdate) >= decade,
           year(speechdate) <= decade + 9) }


save_named_rdata <- function(object, object_name, out_dir = "data") {
  dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)
  assign(object_name, object, envir = environment())
  save(list = object_name,
       file = file.path(out_dir, paste0(object_name, ".RData")),
       compress = "xz") }


build_decade_outputs <- function(df_master, decade) {
  
  df_decade <- filter_to_decade(df_master, decade)
  
  hansard_obj <- df_decade %>%
    transmute(sentence_id, text) %>%
    distinct(sentence_id, .keep_all = TRUE)
  
  debate_meta_obj <- df_decade %>%
    transmute(sentence_id, speechdate, debate) %>%
    distinct(sentence_id, .keep_all = TRUE)
  
  speaker_meta_obj <- df_decade %>%
    transmute(
      sentence_id,
      speaker,
      suggested_speaker#,
      #ambiguous,
      #fuzzy_matched,
      #ignored
    ) %>%
    distinct(sentence_id, .keep_all = TRUE)
  
  file_meta_obj <- df_decade %>%
    transmute(sentence_id,
              speech_id,
              debate_id,
              src_file_id,
              src_image,
              src_column) %>%
    distinct(sentence_id, .keep_all = TRUE)
  
  list(hansard = hansard_obj,
       debate_metadata = debate_meta_obj,
       speaker_metadata = speaker_meta_obj,
       file_metadata = file_meta_obj) }

decades <- seq(1800, 1900, by = 10)

walk(decades, function(d) {
  
  outs <- build_decade_outputs(hansard_c19_improved_speaker_names_2, d)
  
  save_named_rdata(outs$hansard, paste0("hansard_", d))
  save_named_rdata(outs$debate_metadata, paste0("debate_metadata_", d))
  save_named_rdata(outs$speaker_metadata, paste0("speaker_metadata_", d))
  save_named_rdata(outs$file_metadata, paste0("file_metadata_", d)) })


