export let imagepath = 'images';
export let clothesImagepath = 'clothes';

export function setImagePath(path: string) {
  if (path && path !== '') imagepath = path;
}

export function setClothesImagePath(path: string) {
  if (path && path !== '') clothesImagepath = path;
}
