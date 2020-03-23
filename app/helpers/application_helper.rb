module ApplicationHelper
    def document_title
        if @title.present?
            "#{@title} - 隠れ家スイーツ"
        else
            "隠れ家スイーツ"
        end
    end
end
