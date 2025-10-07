const buildPagination = ({ page = 1, limit = 20 }) => {
  const currentPage = Math.max(parseInt(page, 10) || 1, 1);
  const perPage = Math.min(Math.max(parseInt(limit, 10) || 20, 1), 100);
  const skip = (currentPage - 1) * perPage;
  return { currentPage, perPage, skip };
};

const formatPage = (items, total, { currentPage, perPage }) => ({
  data: items,
  pagination: {
    total,
    page: currentPage,
    pageSize: perPage,
    totalPages: Math.ceil(total / perPage) || 1
  }
});

module.exports = {
  buildPagination,
  formatPage
};
