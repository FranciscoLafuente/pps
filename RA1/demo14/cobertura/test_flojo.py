from clasificar import nivel_riesgo


def test_recorre_todo_pero_no_comprueba_nada():
    nivel_riesgo(5, 5)  # rama "alto"
    nivel_riesgo(2, 3)  # rama "medio"
    nivel_riesgo(1, 1)  # rama "bajo"
