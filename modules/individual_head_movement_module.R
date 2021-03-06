individual_head_movement_UI <- function(id) {
  ns = NS(id)
  mainPanel(width = 12,
    fluidRow(
      tags$h3("Performance Summary", class="page-header")
    ),
    fluidRow(
      column(6, uiOutput(ns("head_ori_lr"))),
      column(6, uiOutput(ns("head_pos_lr")))
    ),
    fluidRow(
      tags$h3("Head Orientation Density", class="page-header")
    ),
    fluidRow(
    plot_head_orientation_density_UI(ns("ori_density"))
    )
  )
}

individual_head_movement <- function(input, output, session, df, meta) {
  ns <- session$ns

  observe({
    req(!is.na(df()))
    req(!is.null(df()))
    callModule(plot_head_orientation_density, "ori_density", df)
  })

  output$head_ori_lr <- renderUI({
    req(!is.na(df()))
    req(!is.null(df()))

    timestamp_start = df() %>% filter(Event == "Game Started") %>% select(Timestamp) %>% slice(1) %>% pull(1)
    
    df_h <- df() %>% filter(Timestamp > timestamp_start)
    aggr = df_h %>%
      dplyr::mutate(HeadCameraRotEulerY_wrap = ifelse(HeadCameraRotEulerY > 180, HeadCameraRotEulerY - 360, HeadCameraRotEulerY)) %>%
                    drop_na(HeadCameraRotEulerY) %>%
      dplyr::mutate(head_lr = "Center",
                    head_lr = ifelse(HeadCameraRotEulerY_wrap > 0, "Right", head_lr),
                    head_lr = ifelse(HeadCameraRotEulerY_wrap < 0, "Left", head_lr)) %>%
    group_by(head_lr) %>% 
      dplyr::summarise(s = sum(row_duration, na.rm=T)) %>%
      pivot_wider(names_from = "head_lr", values_from="s")
    
    fallback_text = "No data available."
    if (nrow(aggr) > 0) {
      left_text = paste("<strong>Left Head Orientation:</strong>",
                                sprintf("%.2f", aggr$Left),
                                 "seconds.")
      right_text = paste("<strong>Right Head Orientation:</strong>",
                                sprintf("%.2f",aggr$Right),
                                  "seconds.")
    
    progress_left = tags$span("",class="mini-progress-bar-fill",style=paste0("width:",aggr$Left / (aggr$Left + aggr$Right) * 100, "%;"))
    progress_right = tags$span("",class="mini-progress-bar-fill",style=paste0("width:",aggr$Right / (aggr$Left + aggr$Right) * 100, "%;"))
    
    ui <- HTML(paste(
      "<p style='text-align:left;'>",
      left_text,
      "</p>",
      "<div class='mini-progress-bar' style='width:100px;'>",
      progress_left,
      "</div><br>",
      "<p style='text-align:left;'>",
      right_text,
      "</p>",
      "<div class='mini-progress-bar' style='width:100px;'>",
      progress_right,
      "</div>"
    ))
    } else {
      ui <- HTML(paste(fallback_text))
    }
    return(ui)
  })  
  
  output$head_pos_lr <- renderUI({
    req(!is.na(df()))
    req(!is.null(df()))
    
    timestamp_start = df() %>% filter(Event == "Game Started") %>% select(Timestamp) %>% slice(1) %>% pull(1)
    df_h <- df() %>% filter(Timestamp > timestamp_start)
    aggr = df_h %>%
      drop_na(HeadCameraPosWorldX) %>%
      dplyr::mutate(head_lr = "Center",
                    head_lr = ifelse(HeadCameraPosWorldX > 0, "Right", head_lr),
                    head_lr = ifelse(HeadCameraPosWorldX < 0, "Left", head_lr)) %>%
      group_by(head_lr) %>% 
      dplyr::summarise(Sum = sum(row_duration, na.rm=T)) %>%
      pivot_wider(names_from = "head_lr", values_from="Sum")
    fallback_text = "No data available."
    if (nrow(aggr)) {
      left_text = paste("<strong>Left Head Position:</strong>",
                        sprintf("%.2f", aggr$Left),
                        "seconds.")
      right_text = paste("<strong>Right Head Position:</strong>",
                         sprintf("%.2f", aggr$Right),
                         "seconds.")

      progress_left = tags$span("",class="mini-progress-bar-fill",style=paste0("width:",aggr$Left / (aggr$Left + aggr$Right) * 100, "%;"))
      progress_right = tags$span("",class="mini-progress-bar-fill",style=paste0("width:",aggr$Right / (aggr$Left + aggr$Right) * 100, "%;"))
      
      ui <- HTML(paste(
        "<p style='text-align:left;'>",
        left_text,
        "</p>",
        "<div class='mini-progress-bar' style='width:100px;'>",
        progress_left,
        "</div><br>",
        "<p style='text-align:left;'>",
        right_text,
        "</p>",
        "<div class='mini-progress-bar' style='width:100px;'>",
        progress_right,
        "</div>"
      ))
    } else {
      ui <- HTML(paste(fallback_text))
    }
    return(ui)
  })  
  
}