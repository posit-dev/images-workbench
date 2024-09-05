from pathlib import Path

import jinja2
import typer


def render(image: str, workbench_version: str, python_version: str, r_version: str):
    root_dir = Path(__file__).parent.parent
    image_dir = root_dir / image
    if not image_dir.exists():
        typer.echo(f'Image "{image_dir}" not found')
        raise typer.Exit(code=1)
    image_tpl_dir = image_dir / "template"
    if not image_tpl_dir.exists():
        typer.echo(f'Image template "{image_tpl_dir}" not found')
        raise typer.Exit(code=1)
    image_dir_versioned = image_dir / workbench_version
    if not image_dir_versioned.exists():
        image_dir_versioned.mkdir()
    e = jinja2.Environment(loader=jinja2.FileSystemLoader(image_tpl_dir))
    for tpl_rel_path in e.list_templates():
        tpl = e.get_template(tpl_rel_path)
        if tpl_rel_path.startswith("Containerfile"):
            rendered = tpl.render(
                workbench_version=workbench_version,
                python_version=python_version,
                r_version=r_version,
            )
            with open(image_dir_versioned / f"{image}.std", "w") as f:
                f.write(rendered)
            rendered_min = tpl.render(
                workbench_version=workbench_version,
                python_version=python_version,
                r_version=r_version,
                is_minimal=True,
            )
            with open(image_dir_versioned / f"{image}.min", "w") as f:
                f.write(rendered_min)
            continue
        rendered = tpl.render(
            workbench_version=workbench_version,
            python_version=python_version,
            r_version=r_version,
        )
        rel_path = tpl_rel_path.trim_suffix(".jinja2")
        with open(image_dir_versioned / rel_path, "w") as f:
            f.write(rendered)


if __name__ == "__main__":
    typer.run(render)
