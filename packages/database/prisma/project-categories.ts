import type { Prisma } from "../generated/client/client.js";

const categoryGroups = [
  {
    code: "CMS",
    name: "CMS",
    children: [
      ["COPY_WEBSITE", "Copy Website"],
      ["AI_CUSTOM", "AI / Custom"],
      ["WORDPRESS", "WordPress"],
      ["STRAPI", "Strapi"],
      ["PHP", "PHP"],
      ["NODE", "Node"],
    ],
  },
  {
    code: "ECOMMERCE",
    name: "E-Commerce",
    children: [
      ["AI_CUSTOM", "AI / Custom"],
      ["WOOCOMMERCE", "WooCommerce"],
      ["SHOPIFY", "Shopify"],
      ["PHP", "PHP"],
      ["NODE", "Node"],
    ],
  },
  {
    code: "CUSTOM_WEB",
    name: "Custom Web",
    children: [
      ["AI_CUSTOM", "AI / Custom"],
      ["PHP", "PHP"],
      ["NODE", "Node"],
    ],
  },
  {
    code: "MOBILE_APP",
    name: "Mobile App",
    children: [
      ["PHP", "PHP"],
      ["NODE", "Node"],
    ],
  },
] as const;

export async function seedProjectCategories(tx: Prisma.TransactionClient) {
  for (const group of categoryGroups) {
    const parent = await tx.projectCategory.upsert({
      where: { code: group.code },
      update: {},
      create: { code: group.code, name: group.name },
    });

    if (parent.parentId !== null) {
      throw new Error(`Seed category ${group.code} must be a root category.`);
    }

    for (const [suffix, name] of group.children) {
      const code = `${group.code}_${suffix}`;
      const child = await tx.projectCategory.upsert({
        where: { code },
        update: {},
        create: { code, name, parentId: parent.id },
      });

      if (child.parentId !== parent.id) {
        throw new Error(`Seed category ${code} has an unexpected parent.`);
      }
    }
  }
}
